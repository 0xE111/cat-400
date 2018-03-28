from entities import Entity
import "../wrappers/msgpack/msgpack"


type
  Message* = object {.inheritable.}
  QuitMessage* = object of Message
  EntityMessage* = object of Message
    entity*: Entity
  AddEntityMessage* = object of EntityMessage
  DelEntityMessage* = object of EntityMessage

  MessageHandler = proc(message: ref Message) {.closure.}


var messageHandlers: seq[MessageHandler] = @[]


register(Message)
register(Message, QuitMessage)
register(Message, AddEntityMessage)
register(Message, DelEntityMessage)

method `$`*(message: ref Message): string {.base.} = "Message"
method `$`*(message: ref QuitMessage): string = "Quit"

proc subscribe*(handler: MessageHandler) =
  messageHandlers.add(handler)

proc broadcast*(self: ref Message) =
  for handler in messageHandlers:
    handler(self)

