# Cat-400

"Cat-400" (c4) is a game framework for Nim programming language.

![Teaser](https://cat400.io/media/Screenshot_2019-04-11_12-09-20.jpg)

## Brief overview

"Cat 400" is a cross-platform framework designed to provide nice experience in game development. Written in nim language, it benefits from the language's elegance and expressiveness, as well as compilation to fast native code.

Officially supported platforms are Linux, Mac OS and Windows. Support for other platforms may be added later or implemented by independent contributors.

Key features:
- client-server architecture by default (even for single-player games) with network support
- modularity: all code is split into "systems" (video/user input/networking etc) which work independently
- systems communicate only by sending messages, which allows to avoid tangled code
- ECS (entity-component-system) with custom user components support
- simple overwriting of existing systems and ability to use your own systems
- "presets" (aka templates) which include some reasonable defaults for specific game genre

## Docs

Visit [docs](docs/) folder.

## Wrappers

There are several wrappers which are subpackages of "Cat-400" and may be installed and used separately:

* [enet](https://github.com/c0ntribut0r/cat-400/tree/master/c4/lib/enet)
* [horde3d](https://github.com/c0ntribut0r/cat-400/tree/master/c4/lib/horde3d)
* [bgfx](https://github.com/c0ntribut0r/cat-400/tree/master/c4/lib/bgfx)
* [ode](https://github.com/c0ntribut0r/cat-400/tree/master/c4/lib/ode)
