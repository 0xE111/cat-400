Video system
============

While you can create your own systems for every aspect of your game, `C4` comes with some default ones for physics, video, network etc. They are extremely handy for quick start, but you are free to replace any of them with your favorite one.

This tutorial will cover built-in video system.

C / Horde3d
-----------

Originally, `C4` was using [Horde3d](http://horde3d.org/) as default backend for its video system. It is a lightweight 3D rendering engine with small `C` API. It's extremely easy to set up and use, so it's excellent for prototyping.

However, lack of updates and tiny API make working with `Horde3d` unpleasant on big projects. We won't cover the backend in this tutorial.

The sources may be found at [c4/systems/video/horde3d.nim](../../../c4/systems/video/horde3d.nim). 

C++ / Ogre3d
------------

[Ogre3d](http://www.ogre3d.org) is a mature `C++` 3D engine with a lot of features and documentation. It is a default video backend for `C4`. However, since it's written in `C++`, you will have to use `cpp` backend for `nim`, i.e.

```sh
nim cpp ...
```

Let's see how it works. Understanding it will help you using other backends or even creating your own one.

Basic setup
-----------

Before doing customization, let's ensure that we can compile & run video system as-is.

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
