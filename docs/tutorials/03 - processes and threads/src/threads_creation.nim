# threads_creation.nim
import c4/threads


spawn("thread1"):  # launches a new thread called "thread1"
  for _ in 0..100:
    echo threadName()  # call `threadName()` to get name of currently running thread

spawn("thread2"):
  for _ in 0..100:
    echo threadName()

joinAll()  # call this to wait for all threads to complete
