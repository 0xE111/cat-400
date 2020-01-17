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
  spawn("thread1"):
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

  spawn("thread2"):
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
