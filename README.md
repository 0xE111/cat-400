# Cat-400

"Cat-400" (c4) is a game framework for Nim programming language. Being a framework means that c4 will do all the dirty job for you while you focus on creating your game. Under active development.

## List of other nim game engines/frameworks

Link | Comments
---- | -------
https://github.com/yglukhov/rod | No docs
https://github.com/zacharycarter/zengine | 
https://github.com/Vladar4/nimgame2 | 
https://github.com/ftsf/nico | 
https://github.com/rnentjes/nim-ludens |
https://github.com/dustinlacewell/dadren |
https://github.com/Polkm/nimatoad |
https://github.com/sheosi/tart |
https://github.com/copygirl/gaem | X
https://github.com/dadren/dadren | X
https://github.com/fragworks/frag | X
https://github.com/hcorion/Jonah-Engine | X
https://github.com/jsudlow/cush | X
https://github.com/def-/nim-platformer | X
https://github.com/Vladar4/nimgame | X

## Brief overview

C4 is being developed for custom needs. Please note that it's more educational project rather then professional software, however if you like it you may use it and make contributions.

## ★ Your help required!

C4 tries to be clear and well-designed. Your contribution is highly appreciated! Sometimes even an idea or better design/implementation would be very helpful. Check out [current issues](https://github.com/c0ntribut0r/cat-400/issues).

## TODOs

* GC supports real-time mode which this library makes use of. It means the GC will never run during game frames and will use fixed amount of frame idle time to collect garbage. This leads to no stalls and close to zero compromise on performance comparing to native languages with manual memory management.

## Tutorial

Learn by coding your first game with c4! Less words - let's try to build something.

### Install & display version

First, install latest c4 right from github:

```shell
nimble install https://github.com/c0ntribut0r/cat-400@#head
```

Create test project. 

```shell
mkdir /tmp/test
cd /tmp/test
touch main.nim
```

Now edit `main.nim`. Let's just launch plain c4 without any custom code.

```nim
from c4.core import run

when isMainModule:
  run()
```

Check whether you can launch c4 and show version:

```shell
nim c -r main.nim -v
...
Nim version 0.17.3
Framework version 0.1.1-12
Project version 0.0
```

Our `main.nim` looks empty, but the main job is done under the hood when calling `run()`. C4 initializes loggers, splits process into client and server, launches infinite loops and does many other things. We don't have to implement it ourselves which lets us focus on really important things! You may have a look at options which are available for your app by default:

```shell
./main -h
```

Now let's start customizing.

### Framework configuration

Configuring c4 is nothing more than changing a tuple. The framework uses some reasonable defaults for your project's config (like version: "0.0") but sometimes we'll need to change them. Oh, let's start with `version`:

```nim
from c4.core import run
from c4.conf import config

config.version = "0.1"

when isMainModule:
  run()
```

Now `nim c -r main.nim -v` will say that our project version is `0.1` which is better than default `0.0`. Well, now you know almost everything you need to create your game.

### Client-server

C4 uses client-server architecture. This means that unlike other nim game engines, c4 launches two separate processes (not threads!), one for client and the other for server. Client does all the job for displaying graphics and UI, playing audio and reading user input. Server does the real job - it launches world simulation, handles physics, processes user input etc.

Important fact is that server is always launched. Even if you play a single player mode, your client is still connecting to a local server on the same machine. If you connect to remote host, you may use your local server for client-side prediction (which is an advanced topic).

C4 allows you to launch your app in a "headless mode" - just a server without a client. This is useful if you want to launch your custom server on VPS or so and you don't need the client at all. We will also use this mode during first steps so that we don't have to care about the client. Use `-s` flag to launch server only. You will see something like this (output may vary depending on c4 version):

```shell
nim c -r main.nim --loglevel=DEBUG -s
...
[2018-01-10T21:48:07] SERVER DEBUG: Version 0.1.1-19
[2018-01-10T21:48:07] SERVER DEBUG: Starting server
[2018-01-10T21:48:07] SERVER DEBUG: Server is Loading
[2018-01-10T21:48:07] SERVER DEBUG: EnetNetworkSystem init
[2018-01-10T21:48:07] SERVER DEBUG: Server is Running
```

Quit with `ctrl+C`. Note that we passed `--loglevel` flag to the executable so that we can better know what's going on under the hood.

We haven't defined any specific behavior, so server just runs by default. Now it's time for "hello world" program!
<!-- 
### States

States are something you'll find very helpful while building your app. Explaing what `State` is would be a redundand job - just go to excellent Robert Nystrom's website: http://gameprogrammingpatterns.com/state.html.

C4 relies heavily on states. You will see (and hopefully use) it very often. Let's see an example right now.

C4 has a `Server` object. Let's omit its internals and just focus on its `state` property:

```nim
type
  Server = object of RootObj
    state: ref State
    # ...
```

Server may be in several reasonable states, like `None` (unitialized), `Loading` (initializing internals), `Running` (running subsystems) etc:

```nim
type
  None* = object of State
  Loading* = object of State
  Running* = object of State
```

Each state not only represents what an object is doing, but also allows to perform some state-related actions. For example, when `Server` enters `Loading` state it initializes all its subsystems; when `Server` enters `Running` it launches infinite game loop.

Now let's be destructive and make server just output "hello world" instead of launching that boring game loop! Create new folder for server-related code:

```shell
mkdir server
touch server/states.nim
```

Edit `states.nim` and define a transition to `Loading` state. Transition is defined by `switch` method like this:

```nim
import c4.utils.state
import c4.server
from logging import nil


method switch*(self: var ref State, newState: ref Running, instance: ref Server) =
  # this method will shadow default server's one (which is not a good idea)
  if self of ref Loading:  # if we came from Loading state
    self = newState  # actually swich current (Loading) state to Running
    echo("Hello world")

```

If we now compile our code we'll see no changes:

```shell
nim c -r main.nim --loglevel=DEBUG -s
...
[2018-01-10T22:46:53] SERVER DEBUG: Version 0.1.1-19
[2018-01-10T22:46:53] SERVER DEBUG: Starting server
[2018-01-10T22:46:53] SERVER DEBUG: Server is Loading
[2018-01-10T22:46:53] SERVER DEBUG: EnetNetworkSystem init
[2018-01-10T22:46:53] SERVER DEBUG: Server is Running
```

That's because c4 doesn't see our custom transition definition. Let's fix this by importing our `state` module before calling `run()`:

```nim
from c4.core import run
from c4.conf import config
import server.server_states

config = (
  version: "0.1"
)

when isMainModule:
  run()
```

```shell
nim c -r main.nim --loglevel=DEBUG -s
...
[2018-01-10T22:48:25] SERVER DEBUG: Version 0.1.1-19
[2018-01-10T22:48:25] SERVER DEBUG: Starting server
[2018-01-10T22:48:25] SERVER DEBUG: Server is Loading
[2018-01-10T22:48:25] SERVER DEBUG: EnetNetworkSystem init
Hello world
```

Nice! We just broke our server startup in favor of "Hello world" output. Now revert the destructive changes and go on.

*Warning:* Avoid calling `switch` inside of `switch`. If your state graph is cyclic (i.e. you may switch to already visited states) you may face stack overflow error. -->

<!-- 
### Client

Let's quickly set up a minimal client. It's the same as setting up a server - create `client_states.nim` and import it:

```shell
mkdir client
touch client/client_states.nim
```

```nim
# client_states.nim
from c4.utils.states import State, None, switch
from c4.client import Loading, Running
from logging import nil


method switch*(fr: ref None, to: ref Loading): ref State =
  logging.debug("Loading")
  result = to.switch(new(ref Running))

method switch*(fr: ref Loading, to: ref Running): ref State =
  logging.debug("Running")
  result = to.switch(new(ref None))

method switch*(fr: ref Running, to: ref None): ref State =
  result = to
```

```nim
# main.nim
from c4.core import run
from c4.conf import config
import server.server_states, client.client_states

config.version = "0.1"

when isMainModule:
  run()
```

Ensure your app can launch client and server simultaneously (exclude `-s` flag for now):

```shell
nim c -r main.nim --loglevel=DEBUG
...
[2018-01-04T00:50:39] SERVER DEBUG: Version 0.1.1-15
[2018-01-04T00:50:39] CLIENT DEBUG: Version 0.1.1-15
[2018-01-04T00:50:39] SERVER DEBUG: Process created
[2018-01-04T00:50:39] CLIENT DEBUG: Process created
[2018-01-04T00:50:39] SERVER DEBUG: Loading
[2018-01-04T00:50:39] CLIENT DEBUG: Loading
[2018-01-04T00:50:39] SERVER DEBUG: Running
[2018-01-04T00:50:39] CLIENT DEBUG: Running
[2018-01-04T00:50:39] SERVER DEBUG: Process stopped
[2018-01-04T00:50:39] CLIENT DEBUG: Process stopped
```

As we can see, both client and server are run simultaneously which is perfect.

Before we move further we need to know how everything works.

### Systems & backends

Unlike other game engines, C4 isn't tied to any specific physics/graphics/ui/audio/etc libraries. Instead these "systems" have interfaces and backends (some specific implementations of the interfaces). For example, c4 video system could have an interface like this:

```nim
type
  VideoBackend = object of RootObj

proc init(video: ref VideoBackend, width: int, height: int) {.inline.} = discard
proc drawText(video: ref VideoBackend, value: string) {.inline.} = discard
proc exit(video: ref VideoBackend) {.inline.} = discard
```

Now every class that implements these `init`, `drawText` and `exit` procs can be used as a video backend. So, for example, when starting your game you could implement a test backend which just prints text to the console:

```nim
type
  ConsoleBackend = object of Video

proc drawText(video: ref ConsoleBackend, value: string) {.inline.} =
  echo(value)
```

Next when you get ready you could create a fully-featured `OpenglBackend` which would use sdl+opengl to open a fullscreen window and draw some text.

C4 is shipped with few default backends. Use them to quickly prototype your app and get an MVP. Once you're done you can extend existing backends or write your own ones that will fit exactly your needs. Backends may be set in config:

```nim
# main.nim
...
from backends.network import MySuperFastNetworkBackend

config.networkBackend = new(ref MySuperFastNetworkBackend)
...
```

However, defaults for prototyping are enough for our needs so we won't change anything here. Just keep in mind that there's no magic and all we see is a result of different backends' work.

### Network system

It's fine that we can launch client and server, but how do they communicate? Network system is here to help us! It's automatically initialized right after starting server and client and is ready to send/receive messages. By default c4 uses Enet library (working over UDP) as a backend for client-server communications but you can change it by setting `config.networkBackend`. Now let's make client talk to server.
 -->
