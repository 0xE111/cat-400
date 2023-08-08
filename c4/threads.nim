import times
import os
import std/tables

import c4/messages
import c4/logging


type
  ThreadID* = int8
  ThreadsTable* = Table[string, Channel[ref Message]]
  ThreadUnavailable* = object of CatchableError

var
  channels*: array[16, Channel[ref Message]]
  activeThreads*: set[ThreadID]
  threadID* {.threadvar.}: ThreadID

let
  defaultPollInterval*: Duration = initDuration(milliseconds=100)

template spawnThread*(id: ThreadID, code: untyped) =
  activeThreads.incl(id)
  channels[id].open()

  var thread: Thread[ThreadID]
  thread.createThread(proc(thisThreadID: ThreadID) {.gcsafe.} =
    threadID = thisThreadID
    withLog(DEBUG, "running thread"):
      code
    channels[thisThreadID].close()
    activeThreads.excl(thisThreadID)
  , id)


proc probe*(
  id: ThreadID,
  timeout: Duration,
  pollInterval: Duration = defaultPollInterval,
) {.raises: [ThreadUnavailable].} =
  ## Probe whether specific thread becomes available in `timeout` seconds, checking every `interval` seconds.

  let timeoutTime = epochTime() + timeout.inNanoseconds.int / 1000000
  let sleepTime = (pollInterval.inNanoseconds.int / 1000000).int
  while epochTime() < timeoutTime:
    if id in activeThreads:
      return
    sleep(sleepTime)

  raise newException(ThreadUnavailable, "Thread " & $id & " is not available after " & $timeout & " seconds")


proc joinActiveThreads*(pollInterval: Duration = defaultPollInterval) =
  let sleepTime = (pollInterval.inNanoseconds.int / 1000000).int
  while activeThreads.len > 0:
    debug "waiting for threads to finish", activeThreads, pollInterval
    sleep(sleepTime)
  trace "threads finished"


proc send*(message: ref Message, id: ThreadID) =
  ## Sends a message to a thread.
  ## Usage example:
  ##   new(HelloMessage).send(ThreadID(1))
  ##   (ref PayloadMessage)(x: 1).send(ThreadID(2))
  channels[id].send(message)


when isMainModule:
  import unittest

  type HelloMessage* = object of Message

  suite "Mutithreading":

    test "Spawning thread template":
      const
        thread1 = ThreadID(1)
        thread2 = ThreadID(2)

      spawnThread thread1:
        echo "thread1 waiting for a message"
        discard channels[threadID].recv()
        echo "thread1 received a message"

      spawnThread thread2:
        echo "thread2 waiting for thread1 to appear"
        probe(thread1, timeout=initDuration(seconds=10))
        echo "thread2 sending a message to thread1"
        new(HelloMessage).send(thread1)
        echo "thread2 sent a message to thread1"

      joinActiveThreads()
