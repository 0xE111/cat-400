# Cat 400

"Cat 400" (c4) is a game framework for Nim programming language.

## Brief overview

"Cat 400" is a cross-platform framework designed to provide nice experience in game development. Written in nim language, it benefits from the language's elegance and expressiveness, as well as compilation to fast native code.

Core of "Cat 400" is platform-independent and may be run on every target platform supported by nim. However, default systems (which are optional) have external dependencies, and their officially supported platforms are Linux, Mac OS and Windows. Support for other platforms may be added later or implemented by independent contributors.

Key features:
- client-server multithreading architecture (even for single-player games) with network support
- modularity: all code is split into "systems" (video/user input/networking etc) which work independently
- systems communicate only by sending messages, thus avoiding tangled code
- ECS (entity-component-system) with custom user components support
- simple overwriting of existing systems and ability to create custom systems
- templates which include some reasonable defaults for specific game genre

## Is 2D/3D supported?

3D - out of the box.

2D - yes and no. `C4` is a _framework_, which means that you can use any backend for any of your systems. So, unlike game _engines_, you can make a 2D, 3D or even [4D](https://www.youtube.com/watch?v=0t4aKJuKP0Q) game.

However, currently only 3D video backend is included by default. If you want 2D you should either:
* wait till default 2D backend appears;
* search for third-party backend;
* write your own one.

## GUI / Game Engine

`Cat 400` is not a game engine (and will never be), and everything is quite low-level - there's no gui and every aspect of game is done within source code. No level editor, too.

Feel free to create high-level tools on top of `Cat 400` and share them with community if you have such an opportunity.

## Documentation

### Tutorials

Visit [docs/tutorials](docs/tutorials/) folder - it's the best place to learn `Cat 400`.

### Reference generation

In order to make repo clean, autogenerated reference is not included. You may generate it yourself: from repo root run

```
nimble genDocs
```

Generated reference files will be located in `docs/ref` folder.

## Submodules

Although these modules are part of `Cat-400`, they may be used separately in any project.

[`c4.entities` module](c4/entities.nim) - entity-component system, allowing to create lightweight entities and attach any user-defined components to them, with some basic CRUD operations.

[`c4.messages` module](c4/messages.nim) - `Message` type and any user-defined subtypes, which may be packed and unpacked using msgpack, correctly preserving type information.

[`c4.namedthreads` module](c4/namedthreads.nim) - module for spawning named threads and sending messages between them; allows programmer to focus on his multithreaded app, not on settings up connection between threads.

## Wrappers

There are several wrappers which are subpackages of "Cat-400" and may be installed and used separately:

* [`enet` wrapper](c4/lib/enet) for [Enet networking library](http://enet.bespin.org/)
* [`horde3d` wrapper](c4/lib/horde3d) for [Horde3d graphics engine](http://horde3d.org/)
* [`bgfx` wrapper](c4/lib/bgfx) for [BGFX graphics library](https://github.com/bkaradzic/bgfx)
* [`ode` wrapper](c4/lib/ode) for [Open dynamics engine](https://www.ode.org/)
