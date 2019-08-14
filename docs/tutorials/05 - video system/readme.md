# Video system

While you can create your own systems for every aspect of your game, `C4` comes with some default ones for physics, video, network etc. They are extremely handy for quick start, but you are free to replace any of them with your favorite one.

This tutorial will cover built-in video system.

## Is 2D supported?

Yes and no.
`C4` is a _framework_, which means that you can use any backend for any of your systems. So, unlike game _engines_, you can make a 2D, 3D or even [4D](https://www.youtube.com/watch?v=0t4aKJuKP0Q) game.

However, currently only 3D video backend is included. If you want 2D you should write your own backend (which is rather easy if you follow this tutorial) or search for third-party one.

## C / Horde3d

Originally, `C4` was using [Horde3d](http://horde3d.org/) as default backend for its video system. It is a lightweight 3D rendering engine with small `C` API. It's extremely easy to set up and use, so it's excellent for prototyping.

However, lack of updates and tiny API make working with `Horde3d` unpleasant on big projects. We won't cover the backend in this tutorial.

The sources may be found at [c4/systems/video/horde3d.nim](../../../c4/systems/video/horde3d.nim). 

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
sudo apt-get install libsdl2-2.0 libogre-1.9-dev

# Arch
sudo pacman -S sdl ogre
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
