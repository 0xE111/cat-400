from entities import Entity
import "../wrappers/msgpack/msgpack"


type
  Message* = object {.inheritable.}
  MessageHandler = proc(message: ref Message) {.closure.}


var messageHandlers: seq[MessageHandler] = @[]


register(Message)

method `$`*(message: ref Message): string {.base.} = "Message"

proc subscribe*(handler: MessageHandler) =
  messageHandlers.add(handler)

proc broadcast*(self: ref Message) =
  for handler in messageHandlers:
    handler(self)
