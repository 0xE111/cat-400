## Module for easy spawning new threads and sending messages between them.

import tables
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


var threads = initTable[ThreadName, ThreadInfo]()  # table of all known threads
let threadsPtr = threads.addr  # ptr to threads table, in order to avoid shared memory restrictions
var threadsLock: Lock
threadsLock.initLock()
var currentThreadName {.threadvar.}: string


template spawn*(name: ThreadName, code: untyped) =
  ## Creates a new thread with name `name` and runs `code` inside this thread.
  ## Usage example:
  ##   spawn("thread1") do:
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
        code
    )

proc tryRecv*(): ref Message =
  ## Tries to receive a message, returns message if succeeded
  ## or nil if there's no pending messages.
  withLock threadsLock:
    let res = threadsPtr[][currentThreadName].channel.tryRecv()
    result = if res.dataAvailable: res.msg else: nil

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

proc joinAll*() =
  ## Waits for all threads to terminate.
  ## Threads spawned after this call are not waited for.
  var runningThreads: seq[Thread[ThreadName]] = @[]
  withLock threadsLock:
    runningThreads = toSeq(threads.values).mapIt(it.thread)

  runningThreads.joinThreads()


when isMainModule:
  type
    NumberMessage = object of Message
      number: int

    TerminationMessage = object of Message


  method process(message: ref Message) {.base.} =
    raise newException(ValueError, "Got general message, dunno what to do")

  method process(message: ref NumberMessage) =
    echo &"Calculating {message.number}: {message.number * 2}"

  suite "threads test":
    test "Spawning & communication":

      spawn("generator") do:
        # wait for calculator to be available
        if not waitAvailable("calculator"):
          echo "Calculator is unavailable, shutting down"
          return

        # just send numbers to calculator
        for number in 0..<10:
          echo &"Sending number {number}"
          (ref NumberMessage)(number: number).send("calculator")

        new(TerminationMessage).send("calculator")

      spawn("calculator") do:
        while true:
          let msg = tryRecv()
          if not msg.isNil:
            if msg of ref TerminationMessage:
              echo "Got termination message, shutting down"
              break

            process(msg)

      joinAll()
      echo "All threads finished execution"
