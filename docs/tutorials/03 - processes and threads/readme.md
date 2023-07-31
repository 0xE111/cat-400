Threads
=======

> `c4/threads` may be used separately from `cat 400` framework.

Originally, `Cat 400` was single-threaded, like most of existing nim game engines. However, this is very inefficient: every personal computer has at least couple cores, and you should use all of them for best performance of our app, making calculations as parallel as possible. Even if number of threads is greater than number of cores, [it's still fine](https://stackoverflow.com/questions/3126154/multithreading-what-is-the-point-of-more-threads-than-cores). Also, running different parts of application inside separate threads is a good way of decoupling things.

Running code inside separate thread and sending messages to other threads may be tricky. Fortunately, `c4/threads`  module provides easy interface for that - but under the hood it's just a small wrapper over Nim's `threadpool` and `channels` modules.

> Using `c4/threads` does not dismiss basic multithreading usage rules. Please refer to official Nim docs on threads to understand how it works.

> Using threads requires adding `--threads:on` compiler option. Without it, you'll get "Error: undeclared identifier: 'Thread'".

Threads creation
-------

Create new thread with `spawnThread` template:

```nim
# threads_creation.nim
import std/threadpool
import c4/threads


spawnThread("thread1"):  # launches a new thread called "thread1"
  for _ in 0..100:
    echo threadName  # use `threadName` to get name of currently running thread

spawnThread("thread2"):
  for _ in 0..100:
    echo threadName

sync()  # call this to wait for all threads to complete
```

The program above will output something like this:

```
thread1
thread2
thread2
thread2
thread1
thread1
thread1
thread2
thread2
thread2
thread2
thread2
thread2
thread2
```

As you may see, you just write your code after `spawnThread` statement, and that's it! What you would usually do is to run different systems (physics, graphics etc) in different threads.

Threads communication
----

> This module depends on `c4/messages` for inter-threads communication.

`spawnThread` is a handy wrapper over Nim's `spawn` proc: under the hood, there is a `thread-name -> Channel` mapping in a global variable named `channels`. When you call `spawnThread`, a new thread is created, its name is added to the mapping, and that name leads to thread's channel. So one can easily access any thread's channel by its name.

Let's create a small program that will create two threads. They will send a message between each other, each time incrementing message's value by one. Once value is big enough, `thread1` will send a special `StopMessage` to `thread2`, threads will shut down and program quits.

```nim
# threads_communication.nim
import strformat
import threadpool

import c4/threads
import c4/messages


type
  DataMessage = object of Message
    data: int
  StopMessage = object of Message

# `recv()` and `tryRecv()` return `ref Message` type,
# not `ref DataMessage` -> we need to use methods to
# perform runtime type-specific actions, thus we define
# `process()` and `value()` methods

# these are methods for basic `Message` type
method value(msg: ref Message): int {.base.} = 0
method process(msg: ref Message) {.base.} = discard

# and these are methods for `DataMessage` type
method value(msg: ref DataMessage): int = msg.data
method process(msg: ref DataMessage) = msg.data += 1


when isMainModule:
  spawnThread("thread1"):
    # thread1 will wait for thread2 to appear by calling
    # `probe`; `probe` may accept `timeout`
    # arg (how many seconds to wait) and `interval` arg
    # (how often to check for thread)
    try:
      probe("thread2", timeout=5):
    except ThreadUnavailable:
      echo "Error: thread2 is not available"
      return

    # now we are sure that thread2 is running;
    # send message to thread2
    new(DataMessage).send("thread2")  # by default, data == 0

    # wait for new message from thread2
    while true:
      # this will block execution until message received;
      # for non-blocking behaviour use `tryRecv()`
      let msg = channel[].recv()

      echo &"{threadName}: {msg.value}"  # print current thread name and message value

      msg.process()  # increment message value
      if msg.value > 100:
        echo &"{threadName}: sending stop message"
        new(StopMessage).send("thread2")
        echo &"{threadName}: stopping"
        return  # quit on condition

      msg.send("thread2")  # send message to thread2

  spawnThread("thread2"):
    # this thread is spawned after thread1

    while true:
      let msg = channel[].recv()  # wait until message is received
      if msg of (ref StopMessage):
        echo &"{threadName}: received stop message"
        echo &"{threadName}: stopping"
        return

      echo &"{threadName}: {msg.value}"
      msg.process()  # increment message value
      msg.send("thread1")

  sync()  # wait for all threads
```

The program above will output something like this:

```
...
thread2: 0
thread1: 1
thread2: 2
thread1: 3
thread2: 4
...
thread2: 98
thread1: 99
thread2: 100
thread1: 101
thread1: sending stop message
thread1: stopping
thread2: received stop message
thread2: stopping
```

> Fun fact by Github Copilot: Note that `thread1` is spawned before `thread2`, but `thread2` is started first. This is because `thread1` waits for `thread2` to appear by calling `waitAvailable`.

Main thread
-----------

Main program thread is nothing different from any of `spawn`ed threads. Its name can be accessed using `mainThread` const, and you may communicate with main thread from any other thread as usual:

```nim
# threads_main.nim
import c4/threads
import c4/messages


when isMainModule:
  spawnThread("thread1"):
    # just send dummy message to main thread
    new(Message).send(mainThread)

  # wait for message from thread1
  let msg = channel[].recv()
  echo "Main thread: received message from thread1"
```

Other functions
---------------

```nim
message.send("thread1")  # send message to thread1
message.send()  # send message to current thread itself (loopback)
```

Inspect [c4/threads](../../../c4/threads.nim) or auto-generated docs for complete threads API reference.

Processes
=========

> `c4/processes` may be used separately from `cat 400` framework.

Dealing with processes has a bit similar syntax, but the logic is quite different.

Processes creation
------------------

To create a process, use `run(<process name>)` template:

```nim
# processes_creation.nim
import c4/processes

echo "Common piece of code executed by " & processName  # for each process this will have its unique value

# at this point we start new subprocess;
# as mentioned earlier, every code before this line
# will be executed in every subprocess
run("subprocess1"):
  for i in 0..5:
    echo "#" & $i & " Doing something inside " & processName  # print current process name
    sleep 500

# everything before this line (except run("subprocess1") block)
# will be executed in "subprocess2" process
run("subprocess2"):
  for i in 0..5:
    echo "#" & $i & " Doing something inside " & processName
    sleep 500

echo "Only one process reaches this place: " & processName

# wait for the processes to complete;
# if one process is not running, others are force shut down
dieTogether()
echo "All processes completed"

```

Pay a lot of attention that everyting before `run()` call (except another process run) will be executed in main process and subprocesses. Use it to initialize something common for all processes, for example logging.

> Only main process can run subprocesses and wait for them.

> Under the hood, when you call `run(...)`, the same executable as currently running one is called, with exactly the same args, plus a special arg `--process=<process name>`. The latter defines which `run(...)` code to execute.

Inspect [c4/processes](../../../c4/processes.nim) or auto-generated docs for complete processes API reference.

Processes communication
-----------------------

There's no built-in proc to send messages across processes. However, since messages may be easily serialized to msgpack format, one can easily implement message passing between processes by some network library or message broker.

Wrapping it up
==============

Running client and server processes with multiple threads inside each:

```nim
# processes_and_threads.nim
import strformat
import threadpool
import c4/[processes, threads]


when isMainModule:
  echo &"Running {processName} process"

  run("server"):
    spawnThread("physics"):
      echo &" - Thread {threadName}"
      sleep 2000

    spawnThread("network"):
      echo &" - Thread {threadName}"
      sleep 2000

    sync()  # let's specify module explicitly to not get confused

  run("client"):
    spawnThread("video"):
      echo &" - Thread {threadName}"
      sleep 2000

    spawnThread("network"):
      echo &" - Thread {threadName}"
      sleep 2000

    sync()

  processes.dieTogether()  # let's specify module explicitly to not get confused
  echo "All processes are finished"
```

Now start master process:

```sh
> nim c --threads:on -r processes_and_threads.nim
Running master process
Running server process
 - Thread physics
 - Thread network
Running client process
 - Thread video
 - Thread network
 ```

Or you may start only specific process:

```sh
> nim c --threads:on -r processes_and_threads.nim --process="client"

Running client process
 - Thread video
 - Thread network
```

From this example you probably see where this is going. You may start as many processes as you want, and each process may have as many threads as you want. It is expected that you will separate "server" process which will handle internal "world" state (physics, inventory etc) and "client" process which will handle rendering and user input. However, you may completely skip this and run everything in one process - it's all up to you.

Now you know how to start games using `Cat 400`. Time for [ECS](../04%20-%20ecs/readme.md).
