import c4/loop
import c4/threads
import c4/messages
import c4/logging

type System* = object of RootObj

method process*(self: ref System, message: ref Message) {.base.} =
  warn "dropping unhandled message", message

method update*(self: ref System, dt: float) {.base.} =
  discard

method dispose*(self: ref System) {.base.} =
  discard

method run*(self: ref System, frequency: int = 60) {.base.} =
  var message: ref Message
  var received: bool

  debug "system waiting for initial message"
  message = channel[].recv()
  debug "system received initial message", message
  self.process(message)  # initial message

  loop(frequency=frequency):
    trace "system processing messages"
    while true:
      (received, message) = channel[].tryRecv()
      if not received:
        break
      debug "received message", message
      self.process(message)

    trace "updating system state"
    self.update(dt)

  debug "disposing system"
  self.dispose()
