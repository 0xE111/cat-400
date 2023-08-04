import c4/loop
import c4/threads
import c4/messages
import c4/logging

type System* = object of RootObj

method process*(self: ref System, message: ref Message) {.base.} =
  warn "dropping unhandled message", message

method update*(self: ref System, dt: float) {.base.} =
  discard

method run*(self: ref System, frequency: int = 60) {.base.} =
  debug "waiting for initial message"
  self.process(channel[].recv())  # initial message

  loop(frequency=frequency):
    while true:
      let (received, message) = channel[].tryRecv()
      if not received:
        break
      debug "received message", message
      self.process(message)

    self.update(dt)
