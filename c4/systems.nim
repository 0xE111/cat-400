## Actors-like library.
## Allows users to define "systems", bind them to specific names and run them in separate threads.
## Provides simple interface for communication between systems, both local and remote (in another process or machine).

import unittest
import os
import times
import strformat
import sharedtables
import typetraits

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

var systems: SharedTable[SystemName, SystemInfo]  ## Table of all known systems
systems.init()

# ---- Local systems ----

proc threadEntrypoint[T](name: SystemName) {.thread.} =
  echo &"Entrypoint accepted '{name}' name, type is {T.name}"
  # var system = T(systemName: name)
  # system.run()

proc spawn*(T: typedesc, name: SystemName) =
  ## Given any system type, creates new thread by running `run()` proc and registers it under specific name
  echo &">> Spawning '{name}' of type {T.name}"

  systems.withValue(name, _) do:
    raise newException(NameDuplicationError, "System with this name was already registered")
  do:
    var info = SystemInfo()
    info.channel.open()
    info.thread.createThread(param=name, tp=threadEntrypoint[T])
    systems[name] = info


  # systems.withKey(name) do (key: SystemName, value: var SystemInfo, pairExists: var bool):
  #   if pairExists:
  #     raise newException(NameDuplicationError, "System with this name was already registered")

  #   echo &"withKey '{key}', type {T.name}"

  #   value = SystemInfo()
  #   value.channel.open()
  #   echo &"Creating thread with {key} name"
  #   value.thread.createThread(param = key, tp = threadEntrypoint[T])
  #   echo &"Finished creating thread {key}"

  #   # value.thread.createThread(
  #   #   param = name,
  #   #   tp = proc(nm: SystemName) {.thread.} =
  #   #   echo "Initializing " & nm & " inside a thread"
  #   #   var system = T(systemName: nm)
  #   #   system.run()
  #   # )
  #   pairExists = true

# ---- General operations ----

proc tryRecv*(self: System): ref Message =
  ## Tries to receive a message, returns message if succeeded
  ## or nil if there's no pending messages.
  systems.withValue(self.systemName, value) do:
    let res = value.channel.tryRecv()
    result = if res.dataAvailable: res.msg else: nil
  do:
    raise newException(LibraryError, &"Could not find system '{self.systemName}' in systems table")

# The following one blocks the `systems` table
# proc recv*(self: System): ref Message =
#   ## Wait until new message appears, and return this message
#   systems.withValue(self.systemName, value) do:
#     result = value.channel.recv()
#   do:
#     raise newException(LibraryError, &"Could not find system {self.systemName} in systems table")

proc peek*(self: System): int =
  ## Returns current number of messages pending for specific system
  systems.withValue(self.systemName, value) do:
    result = value.channel.peek
  do:
    raise newException(LibraryError, &"Could not find system '{self.systemName}' in systems table")

proc send*(self: System, message: ref Message) =
  ## Send message to self
  systems.withValue(self.systemName, value) do:
    value.channel.send(message)
  do:
    raise newException(LibraryError, &"Could not find system '{self.systemName}' in systems table")

proc send*(message: ref Message, recipient: SystemName) =
  ## Send message to a specific system
  systems.withValue(recipient, value) do:
    value.channel.send(message)
  do:
    raise newException(LibraryError, &"Could not find system '{recipient}' in systems table")

proc exists*(system: SystemName): bool =
  ## Whether system is available (i.e. spawned or registered as remote one)
  systems.withValue(system, _) do:
    result = true
  do:
    result = false

proc waitAvailable*(system: SystemName, timeout: float = 10.0, interval: float = 1.0): bool =
  ## Returns whether specific system becomes available in `timeout` seconds, checking every `interval` seconds
  let startTime = epochTime()  # in seconds, floating point
  while epochTime() < startTime + timeout:
    if system.exists:
      return true

    sleep(int(interval / 1000))

  return false

# proc joinAll*() =
#   ## Waits for all local systems to terminate.
#   ## Threads spawned after this call are not waited for.
#   var threads: seq[Thread]
#   systems.
#   joinThreads(toSeq(systems.values).mapIt(it.thread))


when isMainModule:
  type
    NumberGenerator = object of System  # this system just generates some numbers

    NumberMessage = object of Message
      number: int

    TerminationMessage = object of Message

  proc run(self: NumberGenerator) =
    echo "Running generator"

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
    echo "Running calculator"
    self.running = true

    while self.running:
      let msg = self.tryRecv()
      if not msg.isNil:
        self.process(msg)

  suite "Systems test":
    test "Spawning & communication":
      NumberGenerator.spawn(name="generator")
      Calculator.spawn(name="calculator")
      sleep(1000)

