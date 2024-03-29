
Tutorial 1 - project setup
==========================

Introduction
------------

`Cat 400` is a game framework - a library that helps programmers to create games. Think of creating any game - you need timer, game loop, drawing something on screen, react to user input etc. `Cat 400` is the thing that will provide all these small blocks of code and (more important) glue them together, thus shifting focus from implementation details to game development itself.

However, `Cat 400` is not an _engine_ - there is no visual editor, no blueprints or whatever. Everything is done in code, and it's up to you to program your game. Of course there is a possibility to build an engine on top of this library, but it's not even in plans. `Cat 400` is a low-level thing, and it will remain like this.

Installing the framework
------------------------

This library doesn't require some special software. You can replace almost all its parts with your own implementations, so there are no external dependencies for new empty project. So, unlike other game frameworks, there are no strict requirements.

However, `Cat 400` ships with some default systems which you may choose and use. For example, you may use `SdlInput` system for user input handling, which I believe is fine for almost all projects. If you do so, there appears a requirement to install `sdl2` shared library into your system, as well as nim-sdl bindings. Same for other systems, each of them has its own requirements. We'll cover this in depth later.

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

Test module import
------------------

Let's just ensure that the framework can be successfully imported:

```nim
# test.nim
import c4/processes


when isMainModule:
  echo "C4 was successfully imported"
```

Compile the code with `nim c -r test` and ensure the message is successfully printed.

Before going further, it's important to mention that you don't have to start each project from scratch - `cat 400` is shipped with some templates which allow you to immediately start coding your game without setting up a project. However, for learning purposes we'll cover creating brand new project from scratch. After this tutorial you should understand how the framework works and that there's no magic inside.

> For every tutorial, you will find sources in [src](src/) folder.

> Everything mentioned in the tutorials is a subject to change until v1.0 is released. Please open an issue if you find inconsistencies.

Now you are ready for [Messages tutorial](../02%20-%20messages/readme.md)
