# Video system

While you can create your own systems for every aspect of your game, `C4` comes with some default ones for physics, video, network etc. They are extremely handy for quick start, but you are free to replace any of them with your favorite one.

This tutorial will cover built-in video system.

## Is 2D supported?

Yes and no.
`C4` is a _framework_, which means that you can use any backend for any of your systems. So, unlike game _engines_, you can make a 2D, 3D or even 4D game.

However, currently only 3D video backend is included. If you want 2D you should write your own backend (which is rather easy if you follow this tutorial) or search for third-party one.

## C++ / Ogre3d

[Ogre3d](http://www.ogre3d.org) is a mature `C++` 3D engine with a lot of features and documentation. It is a default video backend for `C4`. However, since it's written in `C++`, you will have to use `cpp` backend for `nim`, i.e.

```sh
nim cpp ...
```

Let's see how it works. Understanding it will help you using other backends or even creating your own one.

### Pre-installation

Before understanding video system, let's ensure that we can compile & run it.

First, you need to ensure that all required libraries are installed in your system. Ogre video backend requires:
* SDL 2.*
* Ogre 1.*

Install those using your package manager or whatever:

```sh
# Ubuntu / Debian
sudo apt-get install libsdl2 libogre

# Arch
sudo pacman -S sdl2 ogre
```

`C4` already includes partial bindings for Ogre in [c4/lib/ogre/ogre.nim](../../../c4/lib/ogre/ogre.nim), but for sdl2 you need to install [sdl2_nim](https://github.com/Vladar4/sdl2_nim):

```sh
nimble install sdl2_nim
```

### Basic setup

> Source code for basic setup is available at [src/01-base](src/01-base) folder.

`SDL2` requires defining video driver flags for specific platform. It will be done automatically if you include [ogre.nims](../../../c4/systems/video/ogre.nims) config file:

```nim
# main.nims
include "c4.nims"
include "c4/systems/video/ogre.nims"
```

Time to create `main.nim` file:

```nim
import tables

import c4/core
import c4/systems
import c4/systems/video/ogre

when isMainModule:
  core.run(
    clientSystems={
      "video": VideoSystem.new().as(ref System),
    }.toOrderedTable(),
  )
```

Here we imported `c4/systems/video/ogre` - it defines default `VideoSystem` which does nothing except opening a black application window.

Now check that our setup works:

```sh
# pay attention to "cpp" here!
nim cpp -r main.nim -l=debug
```

If you don't see a black window, [open an issue](../../../issues/new).

### Customization

> Source code for custom setup is available at [src/02-custom](src/02-custom) folder.

#### Define custom video system

Since we want to display _something_, we have to extend default `VideoSystem`:

```nim
# systems/video.nim
import logging

import c4/systems
import c4/systems/video/ogre

type CustomVideoSystem* = object of VideoSystem

method init(self: ref CustomVideoSystem) =
  # call base method, which will perform default initialization
  procCall self.as(ref VideoSystem).init()

  # write something to ensure custom `init()` is called
  logging.debug "Initializing custom video system"
```

`as()` template is nothing but type convertion, so `self.as(ref VideoSystem)` equals to `(ref VideoSystem)(self)`.

`procCall self.as(ref VideoSystem).init()` calls base method (i.e. `VideoSystem.init()`). When customizing some method, almost always it's a good idea to call base method first, unless you know how it works and have specific reasons to overwrite it.

Now replace default `VideoSystem` with our custom one:

```nim
# main.nim
import tables

import c4/core
import c4/systems

import systems/video


when isMainModule:
  core.run(
    clientSystems={
      "video": CustomVideoSystem.new().as(ref System),
    }.toOrderedTable(),
  )
```

Ensure that custom video system is used:

```sh
> nim cpp -r main.nim -l=debug
...
[2019-08-14T08:12:15] client DEBUG: Ogre initialized
[2019-08-14T08:12:15] client DEBUG: Initializing custom video system
...
```

#### Assets

Models, shaders, textures - all these things are required for Ogre to work. It's up to you to manage assets - create a directory, collect and load all types of resources your game needs. `Cat 400` doesn't have any general-purpose asset manager.

Here we will use Ogre's built-in resources manager and a `defautMediaDir` const defined in [c4/lib/ogre/ogre.nim](../../../c4/lib/ogre/ogre.nim) (which points to folder with default Ogre assets). Resources manager is automatically initialized and can be accessed as `self.resourcesManager`, see Ogre documentation for detailed instructions on how to use it.

```nim
# systems/video.nim
import logging
import os  # required for `/` proc

import c4/systems
import c4/systems/video/ogre
# in order to use ogre bindings like `self.resourceManager.addResourceLocation`,
# we have to import `c4/lib/ogre/ogre` module;
# to avoid name clash with `c4/systems/video/ogre`, we use `import ... as ...`
import c4/lib/ogre/ogre as ogre_lib

type CustomVideoSystem* = object of VideoSystem

method init(self: ref CustomVideoSystem) =
  # call base method, which will perform default initialization
  procCall self.as(ref VideoSystem).init()

  # write something to ensure custom `init()` is called
  logging.debug "Initializing custom video system"

  logging.debug "Loading custom video resources"

  self.resourceManager.addResourceLocation(defaultMediaDir / "packs" / "SdkTrays.zip", "Zip", resGroup="Essential")
  self.resourceManager.addResourceLocation(defaultMediaDir, "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(defaultMediaDir / "models", "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(defaultMediaDir / "materials" / "scripts", "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(defaultMediaDir / "materials" / "textures", "FileSystem", resGroup="General")
  self.resourceManager.initialiseAllResourceGroups()
```

Scene manager is available at `self.sceneManager`, let's use it to create light:

```nim
  self.sceneManager.setAmbientLight(initColourValue(0.5, 0.5, 0.5))

  let light = self.sceneManager.createLight("MainLight");
  light.setPosition(20.0, 80.0, 50.0);
```

#### Video component

We need to create Ogre nodes and attach 3d models to them. Of course we could instantiate a model right in `CustomVideoSystem.init()` method, but a better way is to make model "belong" to some entity, i.e. create a _video component_ of entity - this way we can create as much entities as we want, and optionally attach & display their components.

Default `VideoSystem` already defines a `Video` component which automatically adds a `ogre.SceneNode` to the scene. Let's define custom  component inherited from the default one. It will load "ogrehead" mesh and attach it to component's node:

```nim
# systems/video.nim
type
  CustomVideo* = object of Video

method attach*(self: ref CustomVideo) =
  # call base method which creates `self.node`
  procCall self.as(ref Video).attach()

  # get reference to video system
  let videoSystem = systems.get("video").as(ref CustomVideoSystem)

  # create Ogre entity (not to be confused with c4's entity)
  let entity = videoSystem.sceneManager.createEntity("ogrehead.mesh")

  # attach Ogre's entity to node
  self.node.attachObject(entity)
```

Now when we attach `CustomVideo` component to any entity, new Ogre node is created and attached to main scene.

> If you component uses any external resources, never forget to release them when component is detached (i.e. define custom `detach()` method). Default `Video` component automatically removes scene node when detached, so we don't need to define `CustomVideo.detach()` method.

For debug purposes, let's draw lines which will represent local `X` and `Y` axis for our node:

```nim
  let line = videoSystem.sceneManager.createManualObject()
  line[].begin("BaseWhiteNoLighting", OT_LINE_LIST)
  # x line
  line[].position(0, 0, 0)
  line[].position(200, 0, 0)
  # y line
  line[].position(0, 0, 0)
  line[].position(0, 100, 0)
  discard line[].end()

  self.node.attachObject(line)
```

#### Entities creation

In order to display something, we need to create entities and attach `CustomVideoComponent`s to them. Let's do it after video system is initialized. When any system finishes initializing, it receives `SystemReadyMessage`, and right at this moment we can create all our entities:

```nim
# systems/video.nim
import c4/entities

# ...

method process(self: ref CustomVideoSystem, message: ref SystemReadyMessage) =
  let ogre = newEntity()
  ogre[ref Video] = new(CustomVideo)
  ogre[ref Video].node.setPosition(0, -20, -300.0)
```

Use following image to understand Ogre's coordinate system:

![Ogre coordinate system](media/ogre_coordinates.jpg)

By default, our camera is located at `(0, 0, 0)` and watching at `(0, 0, -1)` point. That's why we put out entity at `(0, -20, -300)` - it will be located in front of camera, not too close and not too far away.

![Resulting scene](media/scene.jpg)

#### Updating the scene

You probably noticed that something _happens_ in every game. Let's make our scene change. Usually it should be done as a reaction to some event (i.e. after receiving some `Message`), but we'll cover this case in next lessons. For simplicity, let's just rotate all scene nodes each frame.

```nim
# systems/video.nim

method update(self: ref CustomVideoSystem, dt: float) =
  const speed = PI  # rotate PI per second
  let angle = speed * dt
  for video in getComponents(ref Video).values:
    video.node.yaw(initRadian(angle))

  procCall self.as(ref VideoSystem).update(dt)
```

We cannot just rotate by fixed angle each `update()` because time delta between each update may vary. Instead, we use `dt` variable which shows how much _seconds_ passed since previous update.

Also notice that we retrieved all `ref Video` components using `getComponents(ref Video).values`.

#### Drawing somethin more complex

We've covered basic drawing using default `Ogre` backend, but it's up to you to learn `Ogre` library and make it fit you game's requirements.

> Easiest way to draw something without too much mess is to use Ogre's `ManualObject`. It allows you to create and display objects by just defining its vertices and colors. Here is an example of drawing X, Y and Z axis, with red, green, and blue colors respectively:

```nim
  # draw axis
  var manualObject = self.sceneManager.createManualObject()
  manualObject[].begin("BaseWhiteNoLighting", OT_LINE_LIST)

  # X axis, red
  manualObject[].position(0, 0, 0)
  manualObject[].colour(1, 0, 0)
  manualObject[].position(100, 0, 0)

  # Y axis, green
  manualObject[].position(0, 0, 0)
  manualObject[].colour(0, 1, 0)
  manualObject[].position(0, 100, 0)

  # Z axis, blue
  manualObject[].position(0, 0, 0)
  manualObject[].colour(0, 0, 1)
  manualObject[].position(0, 0, 100)

  discard manualObject[].end()

  var node = self.sceneManager.getRootSceneNode().createChildSceneNode()
  node.attachObject(manualObject)
```
