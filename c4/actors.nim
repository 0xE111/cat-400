import tables
import times
import strformat
import unittest
import logging
import os
import locks
import sequtils

import messages


type
  # Actor* = concept actor
  #   # actor is object
  #   actor.run()
  Actor = proc(): void {.thread.}

  ActorID = string

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

  RecipientUnavailableError* = object of Exception


var knownActorsLock: Lock
knownActorsLock.initLock()
var knownActors {.guard:knownActorsLock.}= initTable[ActorID, ActorInfo]()


proc spawn*(kind: ActorKind = Thread, id: ActorId, actor: Actor) =
  ## Registers the actor and launches it
  case kind
    of Thread:
      withLock knownActorsLock:
        knownActors[id] = ActorInfo(kind: Thread)
        knownActors[id].channel.open()
        knownActors[id].thread.createThread(actor)

    of Process:
      raise newException(LibraryError, "Not implemented")


iterator recv*(self: Actor): ref Message =
  raise newException(LibraryError, "Not implemented")


proc send*(self: Actor, message: ref Message, recipient: ActorID, reliable: bool = false) =
  var recipientInfo: ActorInfo

  withLock knownActorsLock:
    if not knownActors.hasKey(recipient):
      raise newException(RecipientUnavailableError, &"Could not find '{recipient}' in known actors table")

    recipientInfo = knownActors[recipient]

  case recipientInfo.kind
    of Thread:
      raise newException(LibraryError, "Not implemented")

    of Process:
      raise newException(LibraryError, "Not implemented")


proc waitAvailable*(actor: ActorID, timeout: float = 10.0, interval: float = 1.0): bool =
  ## Waits until specific actor is available
  let startTime = epochTime()  # in seconds, floating point
  while epochTime() < startTime + timeout:
    withLock knownActorsLock:
      if actor in knownActors:
        return true

    sleep(int(interval / 1000))

  return false


proc joinAll*() =
  var threads: seq[Thread[void]]
  withLock knownActorsLock:
    for info in knownActors.values:
      if info.kind == Thread:
        threads.add(info.thread)
    # var threads = toSeq(knownActors.values.keepItIf(it.kind == Thread).mapIt(it.thread)

  joinThreads(threads)


when isMainModule:
  proc ping() {.thread.} =
    if not waitAvailable("pong"):
      return

    while true:
      echo "ping"

  proc pong() {.thread.} =
    while true:
      echo "Pong"

  suite "Actors test":
    test "Actor spawning":
      Thread.spawn(ActorID("ping"), ping)
      joinAll()
