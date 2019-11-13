import tables
import times
import strformat
import unittest

import messages


type
  Actor* = concept actor
    actor is object
    actor.run()

    let message: ref Message
    actor.store(message)

  ActorKind* = enum
    Thread, Process, Remote

  ActorLocation* = object
    case kind: ActorKind
      of Thread:
        discard

      of Process:
        pid: int

      of Remote:
        ip: string
        port: int16

  UnknownRecipientError* = object of Exception
  DuplicateNameError* = object of Exception


var knownActors = initTable[string, ActorLocation]()


# proc waitAvailable*(actor: string, timeout: float = 10.0, interval: float = 1.0): bool =
#   ## Waits until specific actor is available
#   let startTime = epochTime()  # in seconds, floating point
#   while epochTime() < startTime + timeout:
#     if knownActors.hasKey(actor):
#       return truename: string, actor: Actor

#   return false

proc spawn*(actor: Actor, name: string, kind: ActorKind) {.raises:[DuplicateNameError].} =
  ## Registers the actor and launches it
  assert kind in (Thread, Process), &"Actor kind '{kind}' is not allowed to spawn, use 'Thread' or 'Process' kind instead"

  if knownActors.has(name):
    raise newException(DuplicateNameError, &"Name '{name}' already registered for actor {knownActors[name]}")

    case kind
      of Thread:
        raise newException(LibraryError, "Not implemented")

      of Process:
        raise newException(LibraryError, "Not implemented")


proc send*(self: Actor, message: ref Message, recipient: string, reliable: bool = false) {.raises:[UnknownRecipientError].} =
  if not knownActors.hasKey(recipient):
    raise newException(UnknownRecipientError, &"Could not find '{recipient}' in known actors table")

  let recipientLocation = knownActors[recipient]
  case recipientLocation.kind
    of Thread:
      raise newException(LibraryError, "Not implemented")

    of Process:
      raise newException(LibraryError, "Not implemented")

    of Remote:
      raise newException(LibraryError, "Not implemented")


# when isMainModule:
#   suite "Actors test":
#     test "Pack/unpack base Message type":
#       expect LibraryError:
#         packed = pack(message)
