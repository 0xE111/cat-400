
# Systems

## What is a system?

`System` is a large piece of code which is responsible for one global part of the game. Examples:

* Input system - reads user input (keyboard / mouse)
* Video system - draws image on screen
* Audio system - plays sounds
* Network system - connects players and server
* Physics system - simulates game world

In `Cat 400`, all systems are completely independent and know nothing about each other except names.

## How systems work

There's no restriction on how your system should look like. However, there are some conventions that `c4` follows itself and you are encouraged to follow them too.

### Definition

Each system is an object which encapsulates all information inside its private fields:

```nim
import c4/entities


type PhysicsSystem* = object
  boxes: set[Entity]
  player: Entity
  # whatever else
```

> As you may see, we don't store `boxes`, `player` and other resources in global scope. If we did it, these structures would be initialized at module import, which is unnecessary side effect: your program may import the module but never use its global variables. Also global variables won't allow you to create multiple instances of system, just in case you need it.

### Initialization

The `init` method initializes all internal structures of the system.

```nim
method init*(self: ref PhysicsSystem) =
  self.boxes = @[newEntity(), newEntity()]
  self.player = newEntity()
  # ...
```

### Updating

Use `update` method to update internal state of the system according to delta time (in seconds) since last update.

```nim
method update*(self: ref PhysicsSystem, dt: float) =
  var playerPhysics = self.player[ref Physics]
  playerPhysics.position.x += playerPhysics.velocity.x * dt
  # ...
```

### Disposal

`dispose` method frees resources and terminates the system.

```nim
method dispose*(self: ref PhysicsSystem) =
  #
  getComponents[ref Physics].clear()
  # ...
```

### Message processing

System should be able to process incoming messages. By convention, systems have `process` methods for message handling:

```nim
import c4/messages


method process(self: ref PhysicsSystem, message: ref Message) {.base.}:
  # this is a general method which will capture all messages which don't have specific `process` method; it's a good practice to emit a warning here
  logging.warn(&"No rule for processing {message}")
  # nothing is done, i.e. message is ignored


method process(self: ref PhysicsSystem, message: ref MoveMessage) =
  # this is an example of processing specific message
  var physics = message.entity[ref Physics]
  physics.velocity = message.direction * movementSpeed
  # ...
```

### Running a system

There's a `loop` template which runs your code with specific frequency and provides a `dt` variable (delta time in seconds):

```nim
import strformat
import c4/loop

var i = 0
loop(frequency=30):
  echo &"Current frequency: {1/dt}/s"
  i += 1
  if i > 100:
    break  # use `break` to quit the loop
```

Systems have `run` proc which is usually quite straightforward - it updates the system and processes all pending messages.

> Of course you're not restricted to use the logic above, change it if you need different behavior.

```nim
import c4/loop


proc run*(self: ref PhysicsSystem) =
  loop(frequency=30) do:

    # update the system
    self.update(dt)

    # process all messages
    while true:
      let message = tryRecv()
      if message.isNil:
        break
      self.process(message)
```


<!--

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

method `$`*(self: ref FpsSystem): string =
  "FpsSystem"

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

> It is a good idea to define a `$` method on each system, because system names are used in many debug messages.

Now let's run the framework. In order to do this, we need to call `core.run` proc, passing `OrderedTable[string, ref System]` of client and server systems. In this tutorial we gonna run our `FpsSystem` on server process:

```nim
# main.nim
import tables

import c4/core
import c4/systems

# import our newly created system
import systems/fps

# pay attention that we don't call ``FpsSystem.init()``
when isMainModule:
  core.run(
    serverSystems={
      "fps": FpsSystem.new().as(ref System),
    }.toOrderedTable(),
  )
```

When we write `serverSystems={"fps": FpsSystem.new().as(ref System)}.toOrderedTable()`, we ask `Cat 400` to register the `FpsSystem` system under `fps` name. Names are used to discover systems: later, we can send reach this system by name, i.e. call `systems.get("fps")` and get the instance of `FpsSystem`.

It's fine to call system `"fps"` for this example project, but in real projects you should use something more meaningful, like `"video"` or `"network"`. There's no restrictions on how much and which systems you have.

Now compile and run the code:

```
> nim c -r main.nim -l=debug
...
[2019-04-19T00:42:05] server DEBUG: FPS: 60
[2019-04-19T00:42:05] server DEBUG: FPS: 60
[2019-04-19T00:42:05] server DEBUG: FPS: 60
[2019-04-19T00:42:05] server DEBUG: FPS: 60
[2019-04-19T00:42:05] server DEBUG: FPS: 60
[2019-04-19T00:42:05] server DEBUG: FPS: 60
[2019-04-19T00:42:05] server DEBUG: FPS: 60
[2019-04-19T00:42:05] server DEBUG: FPS: 60
[2019-04-19T00:42:05] server DEBUG: FPS: 60
[2019-04-19T00:42:05] server DEBUG: FPS: 60
[2019-04-19T00:42:05] server DEBUG: FPS: 60
[2019-04-19T00:42:05] server DEBUG: FPS: 60
[2019-04-19T00:42:05] server DEBUG: FPS: 60
[2019-04-19T00:42:05] server DEBUG: FPS: 60
[2019-04-19T00:42:05] server DEBUG: FPS: 60
[2019-04-19T00:42:05] server DEBUG: FPS: 60
```

Our system is successfully running at 60 fps. Congratulations!


Sending and processing messages
-------------------------------

You can create and send messages whenever you like, in every part of code. Usually messages are created as a reaction to some event or some other messages.

Messages are sent to systems only. Each system can receive a message (or deny it) and then process it.

Ping-pong app
-------------

Let's build a very simple "ping-pong" app with two systems which will infinitely send "ping" and "pong" messages to each other. Also, let's increase some counter in each message.

Our project structure will look like this:

```
ping_pong.nimble
ping_pong.nims
ping_pong.nim
messages.nim
systems
  |_pinger.nim
  |_ponger.nim
```

* `ping_pong.nimble` is a package with project description for `nimble` package manager; it's also a hack, without it your `messages.nim` file name will clash with `c4/messages.nim` file
* `ping_pong.nims` - compilation settings, described later
* `ping_pong.nim` is the main file where we configure `Cat 400` and run it
* `messages.nim` is a place for all our messages; we will have 2 messages, thus it's fine to have a single file, but if your project is large it's better to create multiple messages files in `messages` folder
* `systems/pinger.nim`, `systems/ponger.nim` - each system definition lives in its own file

Basic setup
-----------

First, define all messages that we will use:

```nim
# messages.nim
import strformat

import c4/messages


type
  PingMessage* = object of Message
    cnt*: int

  PongMessage* = object of Message
    cnt*: int

method `$`*(self: ref PingMessage): string =
  &"PingMessage ({self.cnt})"

method `$`*(self: ref PongMessage): string =
  &"PongMessage ({self.cnt})"

```

The definition is quite obvious. Of course, sending messages count is quite useless, but we use it to understand how data is sent between systems.

> Try to always define custom `$` method for every type you create. This will help debugging a lot. Otherwise `c4`'s debug messages will have no meaning.

Now we gonna define our systems. `PingerSystem` will send `Ping` messages to `PongerSystem`, the latter will send `Pong` messages as a response.

```nim
# systems/pinger.nim
import c4/systems

import ../messages


type PingerSystem* = object of System

method `$`*(self: ref PingerSystem): string =
  "PingerSystem"
```

Game loop flow
--------------

Here we need some understanding of how systems receive messages. When you send `PongMessage` to `PingerSystem`, the latter immediately stores this message in its message queue. By default all incoming messages will be stored in system's message queue.

When it's `PingerSystem`'s turn to be updated, main game loop calls `PingerSystem.update(dt)` and that method calls `process()` on every message in message queue.

![Message processing](media/message_processing.jpg)

So, to summarize:

* Main game loop infinitely goes through each system in `config.systems` and calls `System.update(dt)`. In our case, it will call `PingerSystem.update(dt)`, `PongerSystem.update(dt)`, `PingerSystem.update(dt)` etc.

> Game loop respects the order of your systems and will update them in the same order as you registered them.

* By default, `System.update(dt)` does only 1 thing: it pulls messages from message queue and calls `System.process(message)` on them.

> `System.update(dt)` respects the order in message queue: if system received `messageA` and then `messageB`, then it's guaranteed that `messageA` will be processed before `messageB`.

Let's create a rule: when `PingerSystem` processes `PongMessage`, it sends `PingMessage` back (with increased counter).

Here's how we do that:

```nim
# systems/pinger.nim
# ...

method process(self: ref PingerSystem, message: ref PongMessage) =
  (ref PingMessage)(cnt: message.cnt + 1).send("ponger")
```

`(ref PingMessage)(cnt: message.cnt + 1)` is a creation of new `ref PingMessage` with field `cnt` increased by `1`. Also note that we can send message to any system using `message.send(<system_name>)`.

That's it! The only problem is that we use `method` here, which means that we need enable `--multimethods:on` compiler switch. You can call it like `nim c --multimethods:on ...`, but `ping_pong.nims` is a better place.

```nim
# ping_pong.nims
switch("multimethods", "on")
```

However, there's even a better way to define `ping_pong.nims`. Some `C4` modules requre additional compiler configuration / switches, and in such cases module will have a `.nims` file with same name. This way you don't need to know all configuration flags required by a specific module - instead you just import module's configuration file into you main `<project>.nims` file, and that's it!

By default `C4` heavily relies on multimethods, so they are switched on in [default configuration file](../../../c4.nims). So let's just include default config file:

```nim
# ping_pong.nims
include "c4.nims"  # include this in every C4 project

# here you can put your own project-specific settings
```

It's up to you to create `systems/ponger.nim` which should be absolutely symmetrical to `systems/pinger.nim` defined above.

Registerning systems
--------------------

Now we need to run our systems in `c4`:

```nim
# ping_pong.nim
import tables

import c4/core
import c4/systems

import systems/pinger
import systems/ponger


when isMainModule:
  core.run(
    serverSystems={
      "pinger": PingerSystem.new().as(ref System),
      "ponger": PongerSystem.new().as(ref System),
    }.toOrderedTable(),
  )

```

Now compile & run the project.

> We registered both our systems on server process, thus we don't need to run client process at all. That's why we add `--mode=server` flag.

```
> nim c -r ping_pong --mode=server -l=debug
...
[2019-04-19T23:07:12] server DEBUG: Version 0.1.1-227
[2019-04-19T23:07:12] server DEBUG: Starting server process
[2019-04-19T23:07:12] server DEBUG: Initializing pinger
[2019-04-19T23:07:12] server DEBUG: Sending SystemReadyMessage(sender: ..., recipient: ...) to PingerSystem
[2019-04-19T23:07:12] server DEBUG: Initializing ponger
[2019-04-19T23:07:12] server DEBUG: Sending SystemReadyMessage(sender: ..., recipient: ...) to PongerSystem
[2019-04-19T23:07:12] server DEBUG: Starting main loop
[2019-04-19T23:07:12] server DEBUG: PingerSystem processing SystemReadyMessage(sender: ..., recipient: ...)
[2019-04-19T23:07:12] server WARN: PingerSystem has no rule to process stored SystemReadyMessage(sender: ..., recipient: ...), ignoring
[2019-04-19T23:07:12] server DEBUG: PongerSystem processing SystemReadyMessage(sender: ..., recipient: ...)
[2019-04-19T23:07:12] server WARN: PongerSystem has no rule to process stored SystemReadyMessage(sender: ..., recipient: ...), ignoring
```

What happened?

* Each system was initialized, and after initialization each system received `SystemReadyMessage` and stored it in message queue.
* Main loop started, it called `PingerSystem.update(dt)`. The update method picked `SystemReadyMessage` from message queue and tried to process it, but we have no rule for it, thus we got a warning.
* Then the same happened to `PongerSystem`.

Ignition
--------

We taught our systems to answer `PingMessage` when processing `PongMessage`, and vice versa. But none of them _received_ a message, there's no one who sent the first message. We gonna fix it.

We know that by the time when `PongerSystem` receives `SystemReadyMessage`, all systems are initialized. Let's make this event a sign to throw first message:

```
# systems/ponger.nim
# ...

method process(self: ref PongerSystem, message: ref SystemReadyMessage) =
  # send first message
  (ref PongMessage)(cnt: 0).send("pinger")
```

Now compile the project:

```
> nim c -r ping_pong --mode=server -l=debug
...
[2019-04-19T23:24:22] server DEBUG: PongerSystem processing SystemReadyMessage(sender: ..., recipient: ...)
[2019-04-19T23:24:22] server DEBUG: Sending PongMessage (0) to PingerSystem
[2019-04-19T23:24:22] server DEBUG: PingerSystem processing PongMessage (0)
[2019-04-19T23:24:22] server DEBUG: Sending PingMessage (1) to PongerSystem
[2019-04-19T23:24:22] server DEBUG: PongerSystem processing PingMessage (1)
[2019-04-19T23:24:22] server DEBUG: Sending PongMessage (2) to PingerSystem
[2019-04-19T23:24:22] server DEBUG: PingerSystem processing PongMessage (2)
[2019-04-19T23:24:22] server DEBUG: Sending PingMessage (3) to PongerSystem
[2019-04-19T23:24:22] server DEBUG: PongerSystem processing PingMessage (3)
[2019-04-19T23:24:22] server DEBUG: Sending PongMessage (4) to PingerSystem
[2019-04-19T23:24:22] server DEBUG: PingerSystem processing PongMessage (4)
[2019-04-19T23:24:22] server DEBUG: Sending PingMessage (5) to PongerSystem
...
```

Awesome! We just set up systems that communicate by sending messages and reacting on them. While it may seem a bit complicated, it's definitely worth it because your systems are truly independent, your code is not tangled and you now have a lot of opportunities like sending messages over network or saving them in order to reproduce ("playback") user inputs. -->
