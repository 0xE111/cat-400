type
  MessageKind* = enum
    msgQuit

  Message* = object {.inheritable.}
  QuitMessage* = object of Message

  MessageQueue* = seq[ref Message]
  MessageHandler = proc(message: ref Message) {.closure.}


var messageHandlers: seq[MessageHandler] = @[]

method `$`*(message: ref QuitMessage): string = "Quit"  # TODO: doesnt work

proc subscribe*(handler: MessageHandler) =
  messageHandlers.add(handler)

proc send*(self: ref Message) =
  for handler in messageHandlers:
    handler(self)


# var queue: MessageQueue = @[]


# proc enqueue*(self: ref Message) =
#   queue.add(self)

# proc flush*() =
#   queue.setLen(0)
