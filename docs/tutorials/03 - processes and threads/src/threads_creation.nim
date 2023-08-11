# threads_creation.nim
import c4/threads
import c4/logging

const
  thread1 = ThreadID(1)
  thread2 = ThreadID(2)

spawnThread thread1:
  for _ in 0..100:
    info "thread running", threadID  # use `threadID` to get ID of currently running thread

spawnThread thread2:
  for _ in 0..100:
    info "thread running", threadID

joinActiveThreads()  # call this to wait for all threads to complete
