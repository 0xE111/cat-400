import deques
import core.messages
import logging
import strformat
import core.entities


type
  MessageQueue* = Deque[ref Message]

  System* = object {.inheritable.}
    messageQueue: MessageQueue

  SystemComponent* = object {.inheritable.}


# ---- System procs ----
method store*(self: ref System, message: ref Message) {.base.} =
  self.messageQueue.addLast(message)

method process*(self: ref System, message: ref Message) {.base.} =
  discard

method init*(self: ref System) {.base.} =
  self.messageQueue = initDeque[ref Message]()

method update*(self: ref System, dt: float) {.base.} =
  # process all messages
  if self.messageQueue.len > 0:
    var message: ref Message
    while self.messageQueue.len > 0:
      message = self.messageQueue.popFirst()
      self.process(message)  # may create new messages during work


# ---- Components support ----
method initComponent*(self: ref System, component: ref SystemComponent) {.base.} =
  raise newException(LibraryError, &"Component {component[]} is not supported by {self[]} system")

method destroyComponent*(self: ref System, component: ref SystemComponent) {.base.} =
  raise newException(LibraryError, &"Component {component[]} is not supported by {self[]} system")

method update*(self: ref SystemComponent, dt: float, entity: Entity) {.base.} =
  discard

# ---- Message procs ----
proc send*(self: ref Message, system: ref System) =
  if not system.isNil:
    system.store(self)

proc send*(self: ref Message, systems: seq[ref System]) =
  for system in systems:
    self.send(system)
