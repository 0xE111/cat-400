import times
import os
import std/sharedtables
export sharedtables
import std/threadpool
import c4/messages

export threadpool.sync

type
  ThreadName* = string
  ThreadProc* = proc() {.closure.}
  ThreadUnavailable* = object of CatchableError

const
  mainThread* = "main"

var
  channels*: SharedTable[string, ref Channel[ref Message]]
  threadName* {.threadvar.}: string
  channel* {.threadvar.}: ref Channel[ref Message]

channels.init()

threadName = "main"
channel = new(Channel[ref Message])
channels[threadName] = channel
channel[].open()


template spawnThread*(name: ThreadName, code: untyped) =
  spawn (proc() =
    channel = new(Channel[ref Message])
    threadName = name

    channels[threadName] = channel
    channel[].open()
    code
    channel[].close()
    channels.del(threadName)
  )()


proc getChannel*(thread: ThreadName): ref Channel[ref Message] {.raises: [ThreadUnavailable].}=
  ## Returns a channel for a thread.
  ## Usage example:
  ##   getChannel("thread2").send(new(HelloMessage))
  ##   getChannel("thread2").send((ref PayloadMessage)(x: 1))

  try:
      return channels.mget(thread)
  except KeyError:
      raise newException(ThreadUnavailable, "Thread " & thread & " is not available")


proc probe*(thread: ThreadName, timeout: float = 10.0, interval: float = 1.0) {.raises: [ThreadUnavailable].} =
  ## Probe whether specific thread becomes available in `timeout` seconds, checking every `interval` seconds.
  ## Usage example:
  ##   try:
  ##     probe("thread2", timeout=30.0)
  ##     new(HelloMessage).send("thread2")
  ##   except ThreadUnavailable:
  ##     echo "thread2 unavailable"

  let startTime = epochTime()  # in seconds, floating point
  while epochTime() < startTime + timeout:
    try:
      discard channels.mget(thread)
      return
    except KeyError:
      discard

    sleep(int(interval / 1000))

  raise newException(ThreadUnavailable, "Thread " & thread & " is not available after " & $timeout & " seconds")


proc send*(message: ref Message, thread: ThreadName) {.raises: [ThreadUnavailable, Exception].} =
    ## Sends a message to a thread.
    ## Usage example:
    ##   new(HelloMessage).send("thread2")
    ##   (ref PayloadMessage)(x: 1).send("thread2")
    getChannel(thread)[].send(message)


proc send*(message: ref Message) =
  channel[].send(message)
