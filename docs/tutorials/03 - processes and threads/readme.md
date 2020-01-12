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
import c4/threads


spawn("thread1") do:  # launches a new thread called "thread1"
  for _ in 0..100:
    echo currentThreadName  # this threadvar contains name of currently running thread

spawn("thread2") do:
  for _ in 0..100:
    echo currentThreadName

joinAll()  # call this to wait for all threads to complete
```

As you may see, you just write your code inside `do:` statement, and that's all!

Threads communication
----

This module depends on `c4/messages` for inter-threads communication.

Let's create a small program that will create two threads. They will send a message between each other, each time incrementing message's value by one. Once value is big enough, threads shut down and program quits.


Processes
=========

