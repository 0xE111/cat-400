from "../core/messages" import Message, subscribe, `$`
from logging import debug
from strformat import `&`


type
  PhysicsSystem* = object {.inheritable.}


method storeMessage*(self: ref PhysicsSystem, message: ref Message) {.base.} =
  logging.debug(&"Physics got new message: {message}")

method init*(self: ref PhysicsSystem) {.base.} =
  messages.subscribe(proc (message: ref Message) = self.storeMessage(message))

method update*(self: ref PhysicsSystem, dt: float) {.base.} =
  discard

{.experimental.}
method `=destroy`*(self: ref PhysicsSystem) {.base.} =
  discard
