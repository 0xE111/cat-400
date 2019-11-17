## Actors-like library.
## Allows users to define "services", bind them to specific names and run them in separate threads.
## Provides simple interface for communication between services, both local and remote (in another process or machine).

import tables
import unittest
import os
import times
import strformat

import messages

type
  ServiceName* = string  ## Each service must have a unique name; this name will be used as a reference to the services

  Service* = object {.inheritable.}
    serviceName: ServiceName

  ServiceKind* = enum
    ## Services may be run locally (using threads) or remotely (using processes)
    Local, Remote

  ServiceInfo = object
    ## Data structure containing service's internal information
    case kind: ServiceKind
      of Local:
        thread: Thread[void]
        channel: Channel[ref Message]

      of Remote:
        ip: string
        port: int16

  NameDuplicationError* = object of Exception


proc run*(self: Service) =
  raise newException(LibraryError, "Undefined `run()` proc")

# TODO: try to use newTable in order to avoid `servicesPtr`
var services = initTable[ServiceName, ServiceInfo]()  ## Table of all known services
let servicesPtr = services.addr  ## Ptr to services table, in order to avoid shared memory restrictions

# ---- Local services ----

template spawn*(T: typedesc[Service], name: ServiceName) =
  ## Given any service type, creates new thread by running `run()` proc and registers it under specific name
  if name in services:
    raise newException(NameDuplicationError, "Service with this name was already registered")

  services[name] = ServiceInfo(kind: Local)
  services[name].channel.open()
  services[name].thread.createThread(proc() {.thread.} =
    T(serviceName: name).run()
  )

# proc spawn*(actorType: typedesc[Actor], name: ActorName) =
#   knownActors[name] = ActorInfo(kind: Thread)
#   knownActors[name].channel.open()
#   knownActors[name].thread.createThread(proc() {.thread.} =
#     actorType(actorName: name).run()
#   )

# ---- Network services ----

# var serverSocket: AsyncSocket

# proc listen*(port: Port) =
#   ## Makes all local services available on specific port
#   var thread: Thread[void]

#   thread.createThread(proc() {.thread.} =
#     var socket = newSocket()
#     socket.bindAddr(port)
#     socket.listen()
#   )

#   # ...

# proc connect*(address: string, port: Port, name: ServiceName)) =


# ---- General operations ----

proc tryRecv*(self: Service): ref Message =
  ## Tries to receive a message, returns message if succeeded
  ## or nil if there's no pending messages.
  let res = servicesPtr[][self.serviceName].channel.tryRecv()
  return if res.dataAvailable: res.msg else: nil

proc recv*(self: Service): ref Message =
  ## Wait until new message appears, and return this message
  servicesPtr[][self.serviceName].channel.recv()

proc peek*(self: Service): int =
  ## Returns current number of messages pending for specific service
  servicesPtr[][self.serviceName].channel.peek

proc send*(message: ref Message, recipient: ServiceName) =
  ## Send message to a specific service
  servicesPtr[][recipient].channel.send(message)

proc exists*(service: ServiceName): bool =
  ## Whether service is available (i.e. spawned or registered as remote one)
  service in servicesPtr[]

proc waitAvailable*(service: ServiceName, timeout: float = 10.0, interval: float = 1.0): bool =
  ## Returns whether specific service becomes available in `timeout` seconds, checking every `interval` seconds
  let startTime = epochTime()  # in seconds, floating point
  while epochTime() < startTime + timeout:
    if service.exists:
      return true

    sleep(int(interval / 1000))

  return false

proc joinAll*() =
  ## Waits for all local services to terminate
  var threads: seq[Thread[void]]
  for info in servicesPtr[].values:
    if info.kind == Local:
      threads.add(info.thread)
  # TODO:
  # var threads = toSeq(services.values.keepItIf(it.kind == Thread).mapIt(it.thread)

  joinThreads(threads)


when isMainModule:
  type
    NumberGenerator = object of Service  # this service just generates some numbers

    NumberMessage = object of Message
      number: int

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


  type Calculator = object  of Service # this service does some calculations

  method process(self: Calculator, message: ref Message) {.base.} =
    raise newException(ValueError, "Got general message, dunno what to do")

  method process(self: Calculator, message: ref NumberMessage) =
    echo &"Calculating {message.number}: {message.number * 2}"

  proc run(self: Calculator) =
    while true:
      self.process(self.recv())

  suite "Services test":
    test "Spawning":
      NumberGenerator.spawn("generator")
      Calculator.spawn("calculator")
      joinAll()
