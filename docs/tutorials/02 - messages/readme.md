
Messages
========

> Before reading this tutorial, it's highly recommended to read [the "Command" chapter](https://gameprogrammingpatterns.com/command.html) of Bob Nystrom's awesome "Game Programming Patterns" book.

> `c4/messages` module does not depend on any other module and may be used separately in any project where messaging is required.

---------------

Our ping pong game is quite straightforward: one moving ball and two paddles which should catch the ball. But under the hood there's a lot:
* a physics system which is responsible for position, velocity and collision of box and paddles;
* a video system which displays all game objects in a window;
* an input system which scans key codes of your keyboard and makes a decision where to move the paddle;
* AI which controls another paddle;
* ...

Most game engines combine these things and allow them live side-by-side. You may see such code:

```nim
var
  # set up graphics stuff ...
  camera = Camera(
    position: vec3f(4, 2, 4),
    target: vec3f(0, 1.8, 0),
    up: vec3f(0, 1, 0),
    fovY: 60
  )
  # ... and some user input ...
  mouseWheelMovement = 0
  mouseXRel = 0
  mouseYRel = 0
  evt: sdl2.Event
  # ... and a bit of game loop ...
  mainLoopRunning = true
  # ... and some video stuff again ...
  model: Model
  shader: Shader
  # ... and a timer
  startTime, endTime: float64
  fps: int
```

It's totally fine to mix everything when you're creating a small game, but it all becomes too tangled when you work on a big project. "Divide and rule" is one of core concepts of `Cat 400`, and different logical parts of application know nothing about each other and have no way to influence each other. Except by using `Message`s.

`Message` is a primitive for sending a piece of information between two non-directly-related parts of application. For example, when position of ball changes, a message containing new position is sent to video system in order to redraw ball in another place.

Under the hood, `Message` [is just an inheritable blank object](../../../c4/messages.nim). One should create custom messages by subclassing `Message` class or its predefined subclasses.

> Since messages are heavily used for delivering information locally and over network, it's very important to make them as tiny as possible, thus saving bandwidth and memory.
>
> For example, you may represent object rotation using either rotation matrix (of size 4x3) or quaternion (of size 4x1), and of course the latter is better.

Messages examples
-----------------

Let's have a look at some messages you could create during development.

For our ping-pong game, we want the paddle to move when player presses left or right arrow key. The message sent from `input` to `physics` system would look like

```nim
import c4/messages


type MovementDirection* = enum
  left, right

type MoveMessage* = object of Message
  direction*: MovementDirection

```

It may be surprising that there's no field for saying _which_ entity we want to move. In fact physics system should already know which paddle belongs to player, so this info is redundant. Remember, try to keep messages as small as possible.

Of course, if your game allows moving different entities with arrow keys, then you would include entity reference as well. It's up to you to think which messages you app needs and what they should store.

Another example may be like this:

```nim
type StartGameMessage* = object of Message
```

Yep, that's it. Sometimes the message _itself_ is enough to represent some information. In this case, receiving a `StartGameMessage` is enough to understand what should be done.

Sending and processing messages
-------------------------------

If using `c4/messages` module separately, it's up to you to decide how to use messages - creating references (`ref Message`) or plain objects (`Message`), storing them in some buffer/pipe or immediately processing after creation by calling some function.

In `Cat 400`, all messages are created as references:

```nim
var msg: ref Message

msg = new(StartGameMessage)
# or
msg = (ref StartGameMessage)()

msg = (ref MoveMessage)(direction: left)
```

There are several reasons to use reference types:

1. `ref Message` is a pointer, which is easy to send across systems on local machine. You don't have to copy entire message content, as you would do with just `Message` type.

2. Message may be sent to multiple destinations, and its lifetime is unknown - one system may not need the message anymore, while the other hasn't processed it yet. Using nim's garbage collection allows you to not care about message lifetime, which you wouldn't be able to achive with raw `ptr Message`.

3. Using `ref` type allows using dynamic dispatch (multimethods), so your methods may change their behaviour based on message type:

```nim
method process*(msg: ref StartGameMessage) =
  echo "Starting game"

method process*(msg: ref MoveMessage) =
  echo &"Moving {msg.direction}"
```

Serializing messages
--------------------

When dealing with network, you need to serialize your message, send it, and then deserialize on the other side. `Cat 400` uses [msgpack4nim](https://github.com/jangko/msgpack4nim) library to serialize messages.

By default, `msgpack4nim` does not include object type into serialized message, so if you pack `ref MoveMessage`, the unpacked type would be the base type - `ref Message`.

`Cat 400` solves this problem by introducing `register` template. This template defines all required methods and procs for including message type into serialized string. Use `msgpack` and `msgunpack` procedures to serialize/deserialize messages:

```nim
# src/messages.nim
import c4/messages


type RunMessage = object of Message
  data: string

method name(msg: ref Message): string {.base.} = "Message"
method name(msg: ref RunMessage): string = "RunMessage"

var
  message: ref Message  # here we will assign message subtype
  packed: string  # here we will store packed message
  unpacked: ref Message  # here we will unpack message

register RunMessage  # now we can serialize RunMessage

message = (ref RunMessage)(data: "test data")  # here message is of type `ref Message`, but in fact we assigned `ref RunMessage` to this variable
assert message.name == "RunMessage"

packed = message.msgpack()
assert stringify(packed) == "1 [ \"test data\" ] "  # `1` means that we packed message type (1 for RunMessage) together with message data

# ... send `packed` over network / save it on disk / whatever ...

# now it's time to restore the message
unpacked = packed.msgunpack()  # when unpacking, we use value `1` to understand that real runtime type of `unpacked` should be `ref RunMessage`
assert unpacked of ref RunMessage  # runtime type is preserved
assert unpacked.name == "RunMessage"
```

> Don't forget to call `register CustomMessageType` on message types if you want to be able to resialize it.

Now that you know how to work with messages, it's time to send them! Continue to [next tutorial](../03%20-%20processes%20and%20threads/readme.md).