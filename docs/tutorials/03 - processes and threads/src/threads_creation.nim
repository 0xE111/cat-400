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
