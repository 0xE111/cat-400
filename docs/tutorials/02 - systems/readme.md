
Tutorial 2 - systems
====================

What is a system?
-----------------

`System` is a core concept of `Cat 400`. `System` is a large piece of code which is responsible for one global part of the game. Examples:

* Input system - reads user input (keyboard / mouse)
* Video system - draws image on screen
* Audio system - plays sounds
* Network system - connects players and server
* Physics system - simulates game world

In `Cat 400`, all systems are completely independent and know nothing about each other. You will never create a code like this:

```nim
var
  # set up graphics stuff ...
  camera = Camera(
    position: vec3f(4, 2, 4),
    target: vec3f(0, 1.8, 0),
    up: vec3f(0, 1, 0),
    fovY: 60
  )
  # ... and some user input ...
  mouseWheelMovement = 0
  mouseXRel = 0
  mouseYRel = 0
  evt: sdl2.Event
  # ... and a bit of game loop ...
  mainLoopRunning = true
  # ... and some video stuff again ...
  model: Model
  shader: Shader
  # ... and a timer
  startTime, endTime: float64
  fps: int
```

It's totally fine to mix everything in single file when you're creating a small game, but it all becomes too tangled when you are working on a big project. "Divide and rule" is one of core concepts of `Cat 400`, and `system` is a good example of it.

How systems work
----------------

Each system is a subclass of `core.systems.System` class. There are 2 methods that may (and should be) overwritten:

```nim
method init*(self: ref System) {.base.}

method update*(self: ref System, dt: float) {.base.}
```

`init` is called before game loop is started, and it is used to set up all internal structures of the system. This method is called automatically, your system may overwrite it but you should never call it yourself.

`update` is called at each game loop iteration. It is used to:
1) Update system (read user input / render frame / send packets over network etc)
2) Process all messages (described later)

Again, `c4` will call this method automatically.

Creating a simple system
------------------------

Let's create a demo system which will do some useless thing - output fps (frames per second) based on delta time before previous and current game loop steps.

`Cat 400` encourages you to use unified directories structure. Create a folder `systems` and create new system file `fps.nim` there:

```nim
# systems/fps.nim
import logging
import strformat

import c4/systems

# define new system
type FpsSystem* = object of System
  # with custom field
  worstFps: int


method init(self: ref FpsSystem) =
  # don't forget to call this, or internal system's structures won't be initialized
  procCall self.as(ref System).init()

  # now init custom fields
  self.worstFps = 0

method update(self: ref FpsSystem, dt: float) =
  # call parent's method, which will process messages
  procCall self.as(ref System).update(dt)

  # calculate fps
  let fps = (1 / dt).int

  # update custom field
  if fps > self.worstFps:
    self.worstFps = fps

  # use c4's logging system to output message
  logging.debug &"FPS: {$fps}"
```

Here we create a `FpsSystem` which is subclass of `System`. All it does is display current fps and store worst result in internal field.

Now let's register this system and run the framework:

```nim
# main.nim
import c4/core
# config provides a variable for registering systems
import c4/config

# import our newly created system
import systems/fps

# register this system on server instance;
# pay attention that we don't call ``init()``;
config.serverSystems["fps"] = FpsSystem.new()

when isMainModule:
  core.run()
```

When we write `config.serverSystems["fps"]`, we ask `Cat 400` to register the system under `fps` name. It's fine for this example project, but in real projects you should use something more meaningful, like `video` or `network`. Names are used to discover systems. There's no restrictions on how much and which systems you have.

Now compile and run the code:

```
> nim c -r main.nim -l=debug
...
[2019-04-19T00:42:05] server DEBUG: FPS: 30
[2019-04-19T00:42:05] server DEBUG: FPS: 30
[2019-04-19T00:42:05] server DEBUG: FPS: 29
[2019-04-19T00:42:05] server DEBUG: FPS: 30
[2019-04-19T00:42:05] server DEBUG: FPS: 30
[2019-04-19T00:42:05] server DEBUG: FPS: 29
[2019-04-19T00:42:05] server DEBUG: FPS: 30
[2019-04-19T00:42:05] server DEBUG: FPS: 29
[2019-04-19T00:42:05] server DEBUG: FPS: 30
[2019-04-19T00:42:05] server DEBUG: FPS: 29
[2019-04-19T00:42:05] server DEBUG: FPS: 30
[2019-04-19T00:42:05] server DEBUG: FPS: 29
[2019-04-19T00:42:05] server DEBUG: FPS: 30
[2019-04-19T00:42:05] server DEBUG: FPS: 29
[2019-04-19T00:42:05] server DEBUG: FPS: 30
[2019-04-19T00:42:05] server DEBUG: FPS: 30
```

Our system is successfully running at 30 fps. Congratulations!