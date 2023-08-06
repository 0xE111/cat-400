
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

> Use `frequency=0` to run at max possible frequency.

Systems have `run` proc which is usually quite straightforward - it updates the system and processes all pending messages.

> Of course you're not restricted to use this logic, change it if you need different behavior.

```nim
import c4/loop
import c4/threads


proc run*(self: ref PhysicsSystem) =
  loop(frequency=30) do:

    # update the system
    self.update(dt)

    # process all messages
    while true:
      let message = channel.tryRecv()
      if message.isNil:
        break
      self.process(message)
```

Creating a simple system
------------------------

Let's create a demo system which will do some useless thing - output fps (frames per second) based on delta time before previous and current game loop steps.

`Cat 400` encourages you to use unified directories structure. Create a folder `systems` and create new system file `fps.nim` there:

```nim
# systems/fps.nim
import strformat

import c4/loop

# define new system
type FpsSystem* = object  # just some object, no inheritance needed
  # with custom field
  worstFps: int


proc init*(self: var FpsSystem) =
  self.worstFps = 0

proc run*(self: var FpsSystem) =
  var i = 0
  loop(frequency=60):
    # calculate fps
    let fps = (1 / dt).int

    # update custom field
    if fps > self.worstFps:
      self.worstFps = fps

    # use c4's logging system to output message
    echo &"FPS: {$fps}"
    inc i
    if i > 100:
      break
```

Here we create a `FpsSystem` which is just an object. All it does is display current fps and store worst result in internal field.

Now let's run the framework. In order to do this, we'll just use `c4/threads` and `c4/processes` modules. In this tutorial we gonna run our `FpsSystem` on server process:

```nim
# main.nim
import threadpool
import strformat
import c4/threads
import c4/processes

# import our newly created system
import systems/fps

when isMainModule:
  run("server"):
    spawnThread("fps"):
      echo &" - Thread {threadName}"
      var system = FpsSystem()
      system.init()
      system.run()

    sync()
```

It's fine to call system `"fps"` for this example project, but in real projects you should use something more meaningful, like `"video"` or `"network"`. There's no restrictions on how much and which systems you have.

Now compile and run the code:

```
> nim c -r main.nim
...
FPS: 61
FPS: 61
FPS: 61
FPS: 62
FPS: 61
FPS: 62
FPS: 61
FPS: 61
FPS: 61
FPS: 61
FPS: 61
FPS: 62
FPS: 61
FPS: 61
FPS: 61
FPS: 61
FPS: 61
FPS: 61
FPS: 61
```

Our system is successfully running at 61 fps. Why not at 60? I have no clue.

Congratulations!

Let's go through built-in systems which will help you to build your first game. It's exciting to not only code but also see a result of your efforts, so let's start with at least showing some window: [input system](../06%20-%20video%20system/readme.md).