Threads
=======

> `c4/threads` may be used separately from `cat 400` framework,

Originally, `Cat 400` was single-threaded, like most of existing nim game engines. However, this is very inefficient: every personal computer has at least couple cores, and you should use all of them for best performance of our app, making calculations as parallel as possible. Even if number of threads is greater than number of cores, [it's still fine](https://stackoverflow.com/questions/3126154/multithreading-what-is-the-point-of-more-threads-than-cores). Also, running different parts of application inside separate threads is a good way of decoupling things.

Running code inside separate thread and sending messages to other threads may be tricky. Fortunately, `c4/threads`  module provides easy interface for that.

> Using `c4/threads` does not dismiss basic multithreading usage rules. Please refer to official Nim docs on threads to understand how it works.

Threads creation
-------

Create new thread with `spawn` template:

```nim
# threads_creation.nim
import c4/threads


spawn("thread1") do:  # launches a new thread called "thread1"
  for _ in 0..100:
    echo threadName()  # call `threadName()` to get name of currently running thread

spawn("thread2") do:
  for _ in 0..100:
    echo threadName()

joinAll()  # call this to wait for all threads to complete
```

As you may see, you just write your code inside `do:` statement, and that's all!

Threads communication
----

This module depends on `c4/messages` for inter-threads communication.

Let's create a small program that will create two threads. They will send a message between each other, each time incrementing message's value by one. Once value is big enough, threads shut down and program quits.


```nim
# threads_communication.nim
import strformat

import c4/threads
import c4/messages


type DataMessage = object of Message
  data: int

# `recv()` and `tryRecv()` return `ref Message` type,
# not `ref DataMessage` -> we need to use methods to
# perform runtime type-specific actions, thus we define
# `process()` and `value()` methods
method value(msg: ref Message): int {.base.} = 0
method process(msg: ref Message) {.base.} = discard

method value(msg: ref DataMessage): int = msg.data
method process(msg: ref DataMessage) = msg.data += 1


when isMainModule:
  spawn("thread1") do:
    # thread1 will wait for thread2 to appear by calling
    # `waitAvailable`; `waitAvailable` may accept `timeout`
    # arg (how many seconds to wait) and `interval` arg
    # (how often to check for thread)
    if not waitAvailable("thread2"):
      echo "Error: thread2 is not available"
      return

    # now we are sure that thread2 is running;
    # send message to thread2
    new(DataMessage).send("thread2")  # by default, data == 0

    # wait for new message from thread2
    while true:
      # this will block execution until message received;
      # for non-blocking behaviour use `tryRecv()`
      let msg = recv()

      echo &"{threadName()}: {msg.value}"  # print current thread name and message value

      msg.process()  # increment message value

      msg.send("thread2")  # send message to thread2
      if msg.value > 100:
        return  # quit on condition

  spawn("thread2") do:
    # this thread is spawned after thread1

    while true:
      let msg = recv()  # wait until message is received
      echo &"{threadName()}: {msg.value}"
      msg.process()  # increment message value

      try:
        msg.send("thread1")
      except KeyError:
        return  # quit if thread1 is unavailable

  joinAll()  # wait for all threads
```

Main thread
-----------

Main program thread is nothing different from any of `spawn`ed threads. Its name can be accessed using `mainThread` const, and you may communicate with main thread from any other thread as usual:

```nim
# threads_main.nim
import c4/threads
import c4/messages


when isMainModule:
  spawn("thread1") do:
    # just send dummy message to main thread
    new(Message).send(mainThread)

  # wait for message from thread1
  let msg = recv()
  echo "Main thread: received message from thread1"
```

Other functions
---------------

```nim
message.send("thread1")  # send message to thread1

message.send()  # send message to current thread itself (loopback)

exists("thread1")  # whether thread1 is currently running

runningThreads()  # sequence of currently running threads' names
```

Inspect [c4/threads](../../../c4/threads.nim) or auto-generated docs for complete threads API reference.

Processes
=========

