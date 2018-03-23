type
  MessageKind* = enum
    msgQuit

  Message* = object {.inheritable.}
  QuitMessage* = object of Message

  MessageQueue* = seq[ref Message]
  MessageHandler = proc(message: ref Message) {.closure.}


var messageHandlers: seq[MessageHandler] = @[]

method `$`*(message: ref Message): string {.base.} = "Message"
method `$`*(message: ref QuitMessage): string = "Quit"

proc subscribe*(handler: MessageHandler) =
  messageHandlers.add(handler)

proc send*(self: ref Message) =
  for handler in messageHandlers:
    handler(self)
