import tables
import unittest
import os
import times

import messages

type
  ActorName* = string

  Actor* = concept actor
    actor is object
    actor.actorName is ActorName
    actor.run()

  ActorKind* = enum
    Thread, Process

  ActorInfo* = object
    case kind: ActorKind
      of Thread:
        thread: Thread[void]
        channel: Channel[ref Message]

      of Process:
        ip: string
        port: int16


var knownActors = initTable[ActorName, ActorInfo]()
let knownActorsPtr = knownActors.addr


template spawn*(actorType: typedesc[Actor], name: ActorName) =
  knownActors[name] = ActorInfo(kind: Thread)
  knownActors[name].channel.open()
  knownActors[name].thread.createThread(proc() {.thread.} =
    actorType(actorName: name).run()
  )

# proc spawn*(actorType: typedesc[Actor], name: ActorName) =
#   knownActors[name] = ActorInfo(kind: Thread)
#   knownActors[name].channel.open()
#   knownActors[name].thread.createThread(proc() {.thread.} =
#     actorType(actorName: name).run()
#   )

proc recv*(self: Actor): ref Message =
  knownActorsPtr[][self.actorName].channel.recv()

proc send*(message: ref Message, recipient: ActorName) =
  knownActorsPtr[][recipient].channel.send(message)

proc waitAvailable*(actor: ActorName, timeout: float = 10.0, interval: float = 1.0): bool =
  ## Waits until specific actor is available
  let startTime = epochTime()  # in seconds, floating point
  while epochTime() < startTime + timeout:
    if actor in knownActorsPtr[]:
      return true

    sleep(int(interval / 1000))

  return false

proc joinAll*() =
  var threads: seq[Thread[void]]
  for info in knownActorsPtr[].values:
    if info.kind == Thread:
      threads.add(info.thread)
  # var threads = toSeq(knownActors.values.keepItIf(it.kind == Thread).mapIt(it.thread)

  joinThreads(threads)


when isMainModule:
  type HelloMessage = object of Message
  type GoodbyeMessage = object of Message

  type Pinger = object
    actorName: ActorName

  method process(self: Pinger, message: ref Message) {.base.} =
    raise newException(ValueError, "Got general message, dunno what to do")

  method process(self: Pinger, message: ref HelloMessage) =
    echo "Got hello message"

  method process(self: Pinger, message: ref GoodbyeMessage) =
    echo "Got goodbye message"

  proc run(self: Pinger) =
    if not waitAvailable("ponger", timeout=2.0, interval=0.5):
      echo "Ponger unavailable -> not running"
      return

    while true:
      self.process(self.recv())

  type Ponger = object
    actorName: ActorName

  proc run(self: Ponger) =
    if not waitAvailable("pinger", timeout=2.0, interval=0.5):
      echo "Pinger unavailable -> not running"
      return

    new(HelloMessage).send("pinger")
    new(GoodbyeMessage).send("pinger")

  suite "Actors test":
    test "Spawning":
      Pinger.spawn(name="pinger")
      Ponger.spawn(name="ponger")
      joinAll()
