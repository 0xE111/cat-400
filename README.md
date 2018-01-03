"Cat-400" (c4) is a game framework for Nim programming language. Being a framework means that c4 will do all the dirty job for you while you focus on creating your game. Under active development.

### List of other nim game engines/frameworks

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

### Brief overview
C4 is being developed for custom needs. Please note that it's more educational project rather then professional software, however if you like it you may use it and make contributions.

The main benefit of c4 is its documentation - I try to make code and docs changes side by side, so docs should always be up-to-date. This is the thing many projects lack.

Less words - let's try to build something.

### Install & display version
First, install latest c4 right from github:

    > nimble install https://github.com/c0ntribut0r/cat-400@#head

Create test project. 

    > mkdir /tmp/test
    > cd /tmp/test
    > touch main.nim
    
Now edit `main.nim`. Let's just launch plain c4 without any custom code.

    from c4.core import run

    when isMainModule:
        run()

Check whether you can launch c4 and show version:

    > nim c -r main.nim -v
    ...
    Nim version 0.17.3
    Framework version 0.1.1-12
    Project version 0.0

Our `main.nim` looks empty, but the main job is done under the hood when calling `run()`. C4 initializes loggers, splits process into client and server, launches infinite loops and does many other things. We don't have to implement it ourselves which lets us focus on really important things! You may have a look at options which are available for your app by default:

    > ./main -h

Now let's start customizing.

### Framework configuration
Configuring c4 is nothing more than changing a tuple. The framework uses some reasonable defaults for your project's config (like version: "0.0") but we won't go far without changing them. Oh, let's start with `version`:

    from c4.core import config, run

    config.version = "0.1"

    when isMainModule:
      run()

Now `nim c -r main.nim -v` with say that our project version is `0.1` which is better than default `0.0`. Well, now you know almost everything you need to create your game.

### Client-server
C4 uses client-server architecture. This means that unlike other nim game engines, c4 launches two separate processes (not threads!), one for client and the other for server. Client does all the job for displaying graphics and UI, playing audio and reading user input. Server does the real job - it launches world simulation, handles physics, processes user input etc.

Important fact is that server is always launched. Even if you play a single player mode, your client is still connecting to a local server on the same machine. If you connect to remote host, you may use your local server for client-side prediction (which is an advanced topic).

C4 allows you to launch your app in a "headless mode" - just a server without a client. This is useful if you want to just serve the game and you don't need the client at all. We will also use this mode during first steps so that we don't have to care about the client. Use `-s` flag to launch server only:

    > nim c -r main.nim --loglevel=DEBUG -s
    ...
    [2018-01-03T00:29:32] DEBUG: Version 0.1.1-13
    [2018-01-03T00:29:32] DEBUG: Server process created
    [2018-01-03T00:29:32] DEBUG: Server stopped

Note that we passed `--loglevel` flag to the executable so that we can better know what's going on.

We haven't defined any specific behavior, so server just stops right after creation. Now it's time for "hello world" program!

### States
States are something you'll find very helpful while building your app. I won't do redundant job and explaing what `State` is - just go to excellent Robert Nystrom's website: http://gameprogrammingpatterns.com/state.html.

C4 relies heavily on states, but it's still developer's job to define states themself as well as transitions between them. Developer also has to choose between "static" and "instantiated" states.

Our server also has a state. Predefined values are:

    type
      Loading* = object of State
      Running* = object of State
      Paused* = object of State

We may use these values but we can create our own ones as well.

When server starts its state is `None` which means "no state". By design server tries to switch state to `Loading` but we haven't defined the transition `None -> Loading` so the state doesn't change. Then server sees `None` state and quits. Let's make server reach `Loading` state and do something.

Create new folder for server-related code:

    > mkdir server
    > touch server/state.nim

Edit `state.nim` and define a transition from `None` to `Loading` state. Transition is defined by `switch` method like this:

    from c4.utils.states import State, None
    from c4.server import Loading  # use built-in Loading state
    from logging import nil  # logging is already set up by c4


    method switch*(fr: ref None, to: ref Loading): ref State =  # define a transition from None to Loading
      logging.debug("Server loading")  # do some preparations (like level/assets loading etc)
      result = to  # successfully switch to new state
      
If we now compile our code we'll see no changes:

    > nim c -r main.nim --loglevel=DEBUG -s
    ...
    [2018-01-03T01:23:43] DEBUG: Server process created
    [2018-01-03T01:23:43] DEBUG: Server stopped

That's because c4 doesn't see our custom transition definition. Let's fix this by importing our `state` module before calling `run()`:

    from c4.core import config, run
    import server.state

    config = (
      version: "0.1"
    )

    when isMainModule:
      run()

Now our program will hang in "Loading" state cause we haven't defined what to do next:

    > nim c -r main.nim --loglevel=DEBUG -s
    ...
    [2018-01-03T01:25:59] DEBUG: Version 0.1.1-13
    [2018-01-03T01:25:59] DEBUG: Server process created
    [2018-01-03T01:25:59] DEBUG: Server loading

Press `ctrl+c` to abort execution. Let's define a fake full cycle - launching server, loading resources, showing intro, running the game and exiting. This will give us a brief overview of possible server state usage.

    from c4.utils.states import State, None, switch  # import "switch" which will act like a forward declaration and suppress linter errors
    from c4.server import Loading, Running
    from logging import nil

    type
      Intro = object of State  # our custom state which is not included in c4 by default

    method switch*(fr: ref None, to: ref Loading): ref State =  # None -> Loading
      logging.debug("Loading assets, building world")
      result = to.switch(new(ref Intro))  # after resource loading switch from Loading to Intro

    method switch*(fr: ref Loading, to: ref Intro): ref State =  # Loading -> Intro
      logging.debug("Playing intro movie")
      result = to.switch(new(ref Running))  # after playing movie run the game

    method switch*(fr: ref Intro, to: ref Running): ref State =  # Intro -> Running
      logging.debug("Running our awesome game")
      result = to.switch(new(ref None))  # after running the game, switch to None which means exit

    method switch*(fr: ref Running, to: ref None): ref State =  # Running -> None
      logging.debug("Moving to final state")
      result = to  # just switch to None

Now compile and launch:

    > nim c -r main.nim --loglevel=DEBUG -s
    ...
    [2018-01-03T02:17:28] DEBUG: Version 0.1.1-13
    [2018-01-03T02:17:28] DEBUG: Server process created
    [2018-01-03T02:17:28] DEBUG: Loading assets, building world
    [2018-01-03T02:17:28] DEBUG: Playing intro movie
    [2018-01-03T02:17:28] DEBUG: Running our awesome game
    [2018-01-03T02:17:28] DEBUG: Moving to final state
    [2018-01-03T02:17:28] DEBUG: Server stopped

It worked! We defined a state graph like this:

    None -> Loading -> Intro -> Running -> None

It's plain now which means that if you try to switch from `Running` back to `Intro` nothing will happen. However you can allow such a switch by defining another `switch` method. So, each arrow is a method, and a set of methods allow you to define your own state graph. Also please don't forget that `None -> Loading` transition will be called automatically on server startup (if defined, of course), but all further state transitions are your responsibility. We'll dive deeper onwards.

Of course it's a dumb idea to play movie on server (it's client's task), and we definitely should do something more than logging messages. But that was a good start!

Now let's leave just a required minimum for our server (`None -> Loading -> Running -> None`):

    from c4.utils.states import State, None, switch
    from c4.server import Loading, Running
    from logging import nil


    method switch*(fr: ref None, to: ref Loading): ref State =
      logging.debug("Loading")
      result = to.switch(new(ref Running))  # after resource loading switch from Loading to Intro

    method switch*(fr: ref Loading, to: ref Running): ref State =
      logging.debug("Running")
      result = to.switch(new(ref None))

    method switch*(fr: ref Running, to: ref None): ref State =
      result = to

Time to set up a client.

### Backends
Unlike other game engines, C4 isn't tied to any specific physics/graphics/ui/audio/etc libraries. Instead these systems have interfaces and "backends" - some specific implementations of the interfaces. For example, c4 video system could have an interface like this:

    type
      VideoBackend = object of RootObj
    
    proc init(video: ref VideoBackend, width: int, height: int) {.inline.} = discard
    proc drawText(video: ref VideoBackend, value: string) {.inline.} = discard
    proc exit(video: ref VideoBackend) {.inline.} = discard
    
Now every class that implements these `init`, `drawText` and `exit` procs can be used as a video backend. So, for example, when starting your game you could implement a test backend which just prints text to the console:

    type
      ConsoleBackend = object of Video

    proc drawText(video: ref ConsoleBackend, value: string) {.inline.} =
      echo(value)

Next when you get ready you could create a fully-featured `OpenglBackend` which would use sdl+opengl to open a fullscreen window and draw some text.

C4 is shipped with few default backends. Use them to quickly prototype your app and get an MVP. Once you're done you can extend existing backends or write your own ones that will fit exactly your needs. Backends may be set in config:

    # main.nim
    ...
    from backends.network import MySuperNetworkBackend

    config.networkBackend = new(ref MySuperNetworkBackend)
    ...

However, currently defaults are enough for our needs so we won't change anything here. Just keep in mind that there's no magic and all we see is a result of different backends' work.
