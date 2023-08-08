# threads_communication.nim
import strformat
import times

import c4/threads
import c4/messages
import c4/logging


type
  DataMessage = object of Message
    data: int
  StopMessage = object of Message

const
  thread1 = ThreadID(1)
  thread2 = ThreadID(2)

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
  spawnThread(thread1):
    # thread1 will wait for thread2 to appear by calling
    # `probe`; `probe` may accept `timeout`
    # arg (how many seconds to wait) and `interval` arg
    # (how often to check for thread)
    try:
      probe(thread2, timeout=initDuration(seconds=5)):
    except ThreadUnavailable:
      echo "Error: thread2 is not available"
      return

    # now we are sure that thread2 is running;
    # send message to thread2
    new(DataMessage).send(thread2)  # by default, data == 0

    # wait for new message from thread2
    while true:
      # this will block execution until message received;
      # for non-blocking behaviour use `tryRecv()`
      let msg = channels[threadID].recv()

      info "received message", threadID, value=msg.value  # print current thread name and message value

      msg.process()  # increment message value
      if msg.value > 100:
        info "sending stop message", threadID
        new(StopMessage).send(thread2)
        info "stopping", threadID
        break  # quit on condition

      msg.send(thread2)  # send message to thread2

  spawnThread(thread2):
    # this thread is spawned after thread1

    while true:
      let msg = channels[threadID].recv()  # wait until message is received
      if msg of (ref StopMessage):
        info "received stop message", threadID
        info "stopping", threadID
        break

      info "received message", threadID, value=msg.value
      msg.process()  # increment message value
      msg.send(thread1)

  joinActiveThreads()  # wait for all threads
