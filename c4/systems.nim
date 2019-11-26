## Actors-like library.
## Allows users to define "systems", bind them to specific names and run them in separate threads.
## Provides simple interface for communication between systems, both local and remote (in another process or machine).

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
  SystemName* = string  ## Each system must have a unique name; this name will be used as a reference to the systems

  System* {.inheritable.} = object
    systemName: SystemName

  SystemInfo = object
    ## Data structure containing system's internal information
    thread: Thread[SystemName]
    channel: Channel[ref Message]

  NameDuplicationError* = object of Exception

var systemsLock: Lock
systemsLock.initLock()
var systems = initTable[SystemName, SystemInfo]()  ## Table of all known systems
let systemsPtr = systems.addr  ## Ptr to systems table, in order to avoid shared memory restrictions

# ---- Local systems ----

proc spawn*(T: typedesc, name: SystemName) =
  ## Given any system type, creates new thread by running `run()` proc and registers it under specific name
  withLock systemsLock:
    if name in systems:
      raise newException(NameDuplicationError, "System with this name was already registered")

    systems[name] = SystemInfo()
    systems[name].channel.open()
    systems[name].thread.createThread(
      param = name,
      tp = proc(name: SystemName) {.thread.} =
        var system = T(systemName: name)
        system.run(),
    )

# ---- General operations ----

proc tryRecv*(self: System): ref Message =
  ## Tries to receive a message, returns message if succeeded
  ## or nil if there's no pending messages.
  withLock systemsLock:
    let res = systemsPtr[][self.systemName].channel.tryRecv()
    result = if res.dataAvailable: res.msg else: nil

proc peek*(self: System): int =
  ## Returns current number of messages pending for specific system
  withLock systemsLock:
    result = systemsPtr[][self.systemName].channel.peek

proc send*(self: System, message: ref Message) =
  ## Send message to self
  withLock systemsLock:
    systemsPtr[][self.systemName].channel.send(message)

proc send*(message: ref Message, recipient: SystemName) =
  ## Send message to a specific system
  withLock systemsLock:
    systemsPtr[][recipient].channel.send(message)

proc exists*(system: SystemName): bool =
  ## Whether system is available (i.e. spawned or registered as remote one)
  withLock systemsLock:
    result = system in systemsPtr[]

proc waitAvailable*(system: SystemName, timeout: float = 10.0, interval: float = 1.0): bool =
  ## Returns whether specific system becomes available in `timeout` seconds, checking every `interval` seconds
  let startTime = epochTime()  # in seconds, floating point
  while epochTime() < startTime + timeout:
    if system.exists:
      return true

    sleep(int(interval / 1000))

  return false

proc joinAll*() =
  ## Waits for all local systems to terminate.
  ## Threads spawned after this call are not waited for.
  var threads: seq[Thread[SystemName]] = @[]
  withLock systemsLock:
    threads = toSeq(systems.values).mapIt(it.thread)

  threads.joinThreads()


when isMainModule:
  type
    NumberGenerator = object of System  # this system just generates some numbers

    NumberMessage = object of Message
      number: int

    TerminationMessage = object of Message

  proc run(self: NumberGenerator) =
    # wait for calculator to be available
    if not waitAvailable("calculator"):
      echo "Calculator is unavailable, shutting down"
      return

    # just send 100 numbers to calculator
    var number = 0
    while number < 10:
      echo &"Sending number {number}"
      (ref NumberMessage)(number: number).send("calculator")
      number += 1

    new(TerminationMessage).send("calculator")


  type Calculator = object of System  # this system does some calculations
    running: bool

  method process(self: var Calculator, message: ref Message) {.base.} =
    raise newException(ValueError, "Got general message, dunno what to do")

  method process(self: var Calculator, message: ref NumberMessage) =
    echo &"Calculating {message.number}: {message.number * 2}"

  method process(self: var Calculator, message: ref TerminationMessage) =
    echo &"Got {message[].type.name}, shutting down"
    self.running = false

  proc run(self: var Calculator) =
    self.running = true

    while self.running:
      let msg = self.tryRecv()
      if not msg.isNil:
        self.process(msg)

  suite "Systems test":
    test "Spawning & communication":
      NumberGenerator.spawn("generator")
      Calculator.spawn("calculator")
      joinAll()
      echo "All systems finished execution"
