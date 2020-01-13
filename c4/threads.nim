## Module for easy spawning new threads and sending messages between them.

import tables
export tables.contains
import unittest
import os
import times
import strformat
import sequtils
import typetraits
import locks

import messages

type
  ThreadName* = string  ## each thread must have a unique name; thread will be accessible by this name

  ThreadInfo = object
    # data structure containing thread's internal information
    thread: Thread[ThreadName]  # thread object itself
    channel: Channel[ref Message]  # channel for sending messages into the thread

  NameDuplicationError* = object of Exception

# table of all known threads;
# setting initial size will prevent from allocating additional space from non-main thread
# (required until sharedtables module is fixed)
var threads = initTable[ThreadName, ThreadInfo](initialSize=16)
let threadsPtr = threads.addr  # ptr to threads table, in order to avoid shared memory restrictions
var threadsLock: Lock
threadsLock.initLock()
var currentThreadName {.threadvar.}: string

proc threadName*(): ThreadName = currentThreadName

# main thread setup
const mainThread* = "main"
currentThreadName = mainThread
threads[currentThreadName] = ThreadInfo()
threads[currentThreadName].channel.open()


template spawn*(name: ThreadName, code: untyped) =
  ## Creates a new thread with name `name` and runs `code` inside this thread.
  ## Usage example:
  ##   spawn("thread1"):
  ##     echo "This block is executed inside thread"

  withLock threadsLock:
    if name in threads:
      raise newException(NameDuplicationError, "Thread with name '" & name & "' was already registered")

    threads[name] = ThreadInfo()
    threads[name].channel.open()
    threads[name].thread.createThread(
      param = name,
      tp = proc(nm: ThreadName) {.thread.} =
        currentThreadName = nm
        onThreadDestruction(proc() =
          withLock threadsLock:
            threadsPtr[][nm].channel.close()
            threadsPtr[].del(nm)
        )
        code
    )

proc tryRecv*(): ref Message =
  ## Tries to receive a message, returns message if succeeded
  ## or nil if there's no pending messages.
  withLock threadsLock:
    let res = threadsPtr[][currentThreadName].channel.tryRecv()
    result = if res.dataAvailable: res.msg else: nil

proc recv*(): ref Message =
  ## Tries to receive a message. Blocks until message is received.
  # var channel: Channel[ref Message]
  # withLock threadsLock:
  #   channel = threadsPtr[][currentThreadName].channel
  # result = channel.recv()
  result = threadsPtr[][currentThreadName].channel.recv()

proc peek*(): int =
  ## Returns number of unread messages for current thread
  withLock threadsLock:
    result = threadsPtr[][currentThreadName].channel.peek

proc send*(message: ref Message) =
  ## Send message to self.
  ## Usage example:
  ##   new(QuitMessage).send()

  withLock threadsLock:
    threadsPtr[][currentThreadName].channel.send(message)

proc send*(message: ref Message, recipient: ThreadName) =
  ## Send message to a specific thread.
  ## Usage example:
  ##   new(QuitMessage).send("thread2")

  withLock threadsLock:
    threadsPtr[][recipient].channel.send(message)

proc exists*(thread: ThreadName): bool =
  ## Checks whether thread is available (i.e. spawned) right now.
  ## Usage example:
  ##   if "thread2".exists:
  ##     new(HelloMessage).send("thread2")

  withLock threadsLock:
    result = thread in threadsPtr[]

proc waitAvailable*(thread: ThreadName, timeout: float = 10.0, interval: float = 1.0): bool =
  ## Returns whether specific thread becomes available in `timeout` seconds, checking every `interval` seconds.
  ## Usage example:
  ##   if "thread2".waitAvailable(timeout=30.0):
  ##     new(HelloMessage).send("thread2")

  let startTime = epochTime()  # in seconds, floating point
  while epochTime() < startTime + timeout:
    if thread.exists:
      return true

    sleep(int(interval / 1000))

  return false

proc runningThreads*(): seq[ThreadName] =
  withLock threadsLock:
    result = toSeq(threadsPtr[].keys)


proc joinAll*() =
  ## Waits for all threads to terminate (except current one and main).
  ## Threads spawned after this call are not taken into account.
  var runningThreads: seq[Thread[ThreadName]] = @[]
  withLock threadsLock:
    runningThreads = toSeq(threads.pairs).filterIt(it[0] notin @[currentThreadName, mainThread]).mapIt(it[1].thread)

  runningThreads.joinThreads()


when isMainModule:
  type
    NumberMessage = object of Message
      number: int

    HelloMessage = object of Message
    TerminationMessage = object of Message


  method process(message: ref Message) {.base.} =
    raise newException(ValueError, "Got general message, dunno what to do")

  method process(message: ref NumberMessage) =
    echo &"Calculating {message.number}: {message.number * 2}"

  suite "Threads test":
    test "Spawning & communication":
      assert "generator" notin runningThreads()

      spawn("generator"):
        # wait for calculator to be available
        assert waitAvailable("calculator")
        assert "calculator" in runningThreads()

        # just send numbers to calculator
        for number in 0..<10:
          echo &"Sending number {number}"
          (ref NumberMessage)(number: number).send("calculator")

        new(TerminationMessage).send("calculator")

      assert waitAvailable("generator")
      assert "generator" in runningThreads()

      spawn("calculator"):
        assert "generator" in runningThreads()

        while true:
          let msg = tryRecv()
          if not msg.isNil:
            if msg of ref TerminationMessage:
              echo "Got termination message, shutting down"
              break

            process(msg)

      assert runningThreads().len == 3

      joinAll()

      assert runningThreads().len == 1

      echo "All threads finished execution"

  test "Communication with master":

    spawn("thread"):
      assert mainThread in runningThreads()
      echo "thread: running"

      echo "thread: sending hello to main"
      new(HelloMessage).send(mainThread)
      while true:
        let msg = tryRecv()
        if not msg.isNil and msg of TerminationMessage:
          echo "thread: received termination message, stopping"
          return

    echo "main: waiting for thread to appear"
    assert waitAvailable("thread")

    while true:
      let msg = tryRecv()
      if not msg.isNil and msg of HelloMessage:
        echo "main: received hello message"
        echo "main: sending termination message"
        new(TerminationMessage).send("thread")
        break

    sleep(200)
    assert "thread" notin runningThreads()

  test "Messages lifetime":

    spawn("old thread"):
      assert waitAvailable("new thread")
      echo "Sending message"
      block:
        (ref NumberMessage)(number: 10).send("new thread")
      GC_fullCollect()

    spawn("new thread"):
      var msg: ref Message
      echo "Waiting for message"
      while true:
        msg = tryRecv()
        if not msg.isNil:
          echo "Received message"
          msg.process()
          break

      GC_fullCollect()
      for i in 0..<5:
        echo $i
        sleep(1000)
        msg.process()
        GC_fullCollect()

      assert true

    echo "Waiting for all threads"
    joinAll()

  test "Messages disposal":

    spawn("sender"):
      assert waitAvailable("recipient")

      let baseMemory = getOccupiedMem()
      var currentMemory: type(baseMemory)

      for i in 0..<100000:
        (ref NumberMessage)(number: 1).send("recipient")
        currentMemory = getOccupiedMem()
        echo &"Sender: msg #{i}, mem diff: {(currentMemory - baseMemory) / baseMemory}%"
        GC_fullCollect()

      assert currentMemory / baseMemory <= 1.1

    spawn("recipient"):

      let baseMemory = getOccupiedMem()
      var currentMemory: type(baseMemory)
      var msg: ref Message

      while true:
        msg = tryRecv()
        if not msg.isNil:
          currentMemory = getOccupiedMem()
          echo &"Recipient: mem diff: {(currentMemory - baseMemory) / baseMemory}%"
          GC_fullCollect()

        if "sender" notin runningThreads():
          break

      assert currentMemory / baseMemory <= 1.1

    joinAll()
