import deques
from core.messages import Message, `$`
from logging import debug
from strformat import `&`


type
  MessageQueue* = Deque[ref Message]

  System* = object {.inheritable.}
    messageQueue: MessageQueue


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

# ---- Message procs ----
proc send*(self: ref Message, system: ref System) =
  if not system.isNil:
    system.store(self)

proc send*(self: ref Message, systems: seq[ref System]) =
  for system in systems:
    self.send(system)
