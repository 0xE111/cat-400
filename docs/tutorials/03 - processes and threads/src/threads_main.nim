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