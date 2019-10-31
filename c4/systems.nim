import deques
import logging
import strformat
import tables

import messages


type
  System* {.inheritable.} = object
    messageQueue: Deque[ref Message]

var systemsMap* = initOrderedTable[string, ref System]()  ## variable which stores all active systems for current process (mode)

# ---- System procs ----
method `$`*(self: ref System): string {.base.} =
  "System"

method store*(self: ref System, message: ref Message) {.base.} =
  self.messageQueue.addLast(message)

method process*(self: ref System, message: ref Message) {.base.} =
  logging.warn &"{$(self)} has no rule to process stored {$(message)}, ignoring"

method init*(self: ref System) {.base.} =
  ## Before running game loop, each system is initialized by automatically calling ``init`` method. Use it to initialize internal structures of your custom systems.
  ## Don't forget to call base method ``procCall self.as(ref System).init()`` which will initialize message queue.
  self.messageQueue = initDeque[ref Message]()

method update*(self: ref System, dt: float) {.base.} =
  ## Perform update in each game loop step. Overwrite this in order to update your custom system.
  ## Don't forget to call ``procCall self.as(ref System).update(dt)`` which will process all messages in message queue.
  if self.messageQueue.len > 0:
    var message: ref Message
    while self.messageQueue.len > 0:
      message = self.messageQueue.popFirst()
      logging.debug &"{$(self)} processing {$(message)}"
      self.process(message)  # may create new messages during work


# ---- Message procs ----
proc send*(self: ref Message, system: ref System) =
  logging.debug &"Sending {$(self)} to {$(system)}"
  system.store(self)

proc send*(self: ref Message, systemName: string) =
  self.send(systemsMap[systemName])

proc send*(self: ref Message, systemsNames: seq[string]) =
  for systemName in systemsNames:
    self.send(systemName)


# ---- messages ----
type
  SystemReadyMessage* = object of Message  ## \
    ## This message is sent to a system when its initialization is complete

  SystemQuitMessage* = object of Message  ## \
    ## This message is a signal to disconnect and terminate systems and whole process

messages.register(SystemReadyMessage)
messages.register(SystemQuitMessage)


# ---- helpers ----
template `as`*(instance: typed, T: typedesc): untyped =
  ## Converts ``instance`` to ``T`` type: ``createEntityMessage.as(ref Message)``
  (T)(instance)
