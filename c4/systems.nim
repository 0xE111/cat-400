from deques import Deque, initDeque, addLast, items, len
from core.messages import Message, `$`
from logging import debug
from strformat import `&`


type
  MessageQueue* = Deque[ref Message]

  System* = object {.inheritable.}
    messageQueue: MessageQueue


# ---- MessageQueue procs ----
proc clear*(self: var MessageQueue) =
  self = initDeque[ref Message]()

proc add*(self: var MessageQueue, value: ref Message) =
  self.addLast(value)

# ---- System procs ----
method store*(self: ref System, message: ref Message) {.base.} =
  self.messageQueue.add(message)
  logging.debug(&"Stored new message: {message}")

method process*(self: ref System, message: ref Message) {.base.} =
  discard

method init*(self: ref System) {.base.} =
  # init message queue and set up message storing
  self.messageQueue.clear()
  messages.subscribe(proc (message: ref Message) = self.store(message))

method update*(self: ref System, dt: float) {.base.} =
  # process all messages
  if self.messageQueue.len > 0:
    for message in self.messageQueue.items():
      self.process(message)
    self.messageQueue.clear()
