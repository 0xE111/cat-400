
Tutorial 1 - project setup
==========================

Introduction
------------

`Cat 400` is a game framework - a library that helps programmers to create games. Think of creating any game - you need timer, game loop, drawing something on screen, react to user input etc. `Cat 400` is the thing that will provide all these small blocks of code and (more important) glue them together, thus shifting focus from implementation details to game development itself.

However, `Cat 400` is not an _engine_ - there is no visual editor, no blueprints or whatever. Everything is done in code, and it's up to you to program your game. Of course there is a possibility to build an engine on top of this library, but it's not even in plans. `Cat 400` is a low-level thing, and it will remain like this.

Project setup
-------------

This library doesn't require some special software. You can replace almost all its parts with your own implementations, so there are no external dependencies for new empty project. So, unlike other game frameworks, there is no strict `bgfx` or `sdl` requirements.

However, `Cat 400` ships with some default systems which you may choose and use. For example, you may use `sdl` system for user input handling, which I believe is fine for almost all projects. If you do so, there appears a requirement to install `sdl` shared library into your system. Same for other systems, each of them have its own requirements. We'll cover this in depth later.

Let's ensure that we can run just empty project.

First, install latest `Cat 400` if you haven't done so. The following command will install latest version of libarary right from the repo:

```
nimble install https://github.com/c0ntribut0r/cat-400@#head
```

If you query for installed packages, you will see that `Cat 400` is named as `c4`, which is a shortand:

```
> nimble list -i | grep c4
c4  [#head]
```

Now create a simple file:

```nim
# main.nim
import c4/core

when isMainModule:
  core.run()
```

Compile the file and run it:

```
nim c -r main.nim
```

You may think that nothing happens and the program is stuck, and it's true - it's stuck in an empty infinite game loop. Let's kill the process (`Ctrl` + `C`) and ensure it's true - but for that we need to discover how to change log level. Let's ask for help:

```
> ./main -h
    -v, --version - print version
    -l, --loglevel=[all|debug|info|notice|warn|error|fatal|none] - specify log level
    -h, --help - print help
    -m, --mode=[client|server|multi] - launch server/client/both
```

Ok, it seems that `-l` flag is what we want. By default the framework sets `info` log level, but it's highly recommended to use `debug` during development.

```
> ./main -l=debug
[2019-04-18T23:32:26] multi DEBUG: Version 0.1.1-221
[2019-04-18T23:32:26] server DEBUG: Version 0.1.1-221
[2019-04-18T23:32:26] server DEBUG: Starting server process
[2019-04-18T23:32:26] server DEBUG: Starting main loop
[2019-04-18T23:32:26] client DEBUG: Version 0.1.1-221
[2019-04-18T23:32:26] client DEBUG: Starting client process
[2019-04-18T23:32:26] client DEBUG: Starting main loop
```

Great, we just got a plenty of useful information. First, we know that I made at least 221 commits in order to make this thing work, so put a star to this repo. Second, you may see that there are `server` and `client` records, which means that this framework uses "client-server" architecture (we'll learn about it later). Third, we see that both client and server successfully entered the main game loop. Awesome.

If you inspect the folder with executable, you will find separate `.log` files for client and server.

Sources
-------

You will find sources for this and other tutorials in [src](src/) folder.
