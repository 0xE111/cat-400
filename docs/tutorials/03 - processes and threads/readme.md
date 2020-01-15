Threads
=======

> `c4/threads` may be used separately from `cat 400` framework.

Originally, `Cat 400` was single-threaded, like most of existing nim game engines. However, this is very inefficient: every personal computer has at least couple cores, and you should use all of them for best performance of our app, making calculations as parallel as possible. Even if number of threads is greater than number of cores, [it's still fine](https://stackoverflow.com/questions/3126154/multithreading-what-is-the-point-of-more-threads-than-cores). Also, running different parts of application inside separate threads is a good way of decoupling things.

Running code inside separate thread and sending messages to other threads may be tricky. Fortunately, `c4/threads`  module provides easy interface for that.

> Using `c4/threads` does not dismiss basic multithreading usage rules. Please refer to official Nim docs on threads to understand how it works.

> Using threads requires adding `--threads:on` compiler option. Without it, you'll get "Error: undeclared identifier: 'Thread'".

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

> `c4/processes` may be used separately from `cat 400` framework.

Dealing with processes has a bit similar syntax, but the logic is quite different.

Processes creation
------------------

To create a process, use `run(<process name>)` template:

```nim
# processes_creation.nim
import strformat

import c4/processes


echo "This piece of code is executed in every process (master, subprocess1, subprocess2)"

echo &"Current process name: {processName()}"  # for each process this will have its unique value

# at this point we start new subprocess;
# as mentioned earlier, every code before this line
# will be executed in every subprocess
run("subprocess1") do:
  for _ in 0..5:
    echo processName()  # print current process name
    sleep 1000

# everything before this line (except run("subprocess1") block)
# will be executed in "subprocess2" process
run("subprocess2") do:
  for _ in 0..100:
    echo processName()
    sleep 1000

echo "Only main process reaches this place"

# wait for the processes to complete;
# if one process is not running, others are force shut down
dieTogether()
```

Pay a lot of attention that everyting before `run()` call (except another process run) will be executed in main process and subprocesses. Use it to initialize something common for all processes, for example logging.

> Only main process can run subprocesses and wait for them.

> Under the hood, when you call `run(...)`, the same executable as currently running one is called, with exactly the same args, plus a special arg `--process=<process name>`. The latter defines which `run(...)` code to execute.

Inspect [c4/processes](../../../c4/processes.nim) or auto-generated docs for complete processes API reference.

Processes communication
-----------------------

There's no built-in opportunity to send messages across processes. However, since messages may be easily serialized to msgpack format, one can easily implement message passing between processes if needed.

Wrapping it up
==============

Running client and server with multiple threads inside each:

```nim
# processes_and_threads.nim
import strformat

import c4/[processes, threads]


when isMainModule:
  echo &"Running {processName()} process"

  run("server") do:
    spawn("physics") do:
      echo &" - Thread {threadName()}"
      sleep 2000

    spawn("network") do:
      echo &" - Thread {threadName()}"
      sleep 2000

    threads.joinAll()  # let's specify module explicitly to not get confused

  run("client") do:
    spawn("video") do:
      echo &" - Thread {threadName()}"
      sleep 2000

    spawn("network") do:
      echo &" - Thread {threadName()}"
      sleep 2000

    threads.joinAll()

  processes.dieTogether()  # let's specify module explicitly to not get confused
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

Now you know how to start games using `Cat 400`. Time for [ECS](../04%20-%20ecs/readme.md).
