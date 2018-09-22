# Cat-400

"Cat-400" (c4) is a game framework for Nim programming language.

![Teaser](https://github.com/c0ntribut0r/cat-400/raw/master/teaser.jpg)

## Wrappers

There are several wrappers which are subpackages of "Cat-400" and may be installed and used separately:

* [enet](https://github.com/c0ntribut0r/cat-400/tree/master/c4/wrappers/enet)
* [horde3d](https://github.com/c0ntribut0r/cat-400/tree/master/c4/wrappers/horde3d)
* [ode](https://github.com/c0ntribut0r/cat-400/tree/master/c4/wrappers/ode)

## Brief overview

C4 is more educational project rather then professional software, however if you like it you may use it and make contributions.

Key features:
- client-server architecture by default (even for single-player games) with network support
- modularity: all code is split into "systems" (video/user input/networking etc) which work independently
- systems communicate only by sending messages, which allows to avoid tangled code
- ECS (entity-component-system) with custom user components support
- simple overwriting of existing systems and ability to use your own systems
- "presets" (aka templates) which include some reasonable defaults for specific game genre

## Docs

* [Introduction](https://cat400.io/introduction/)
