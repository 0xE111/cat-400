type
  MessageKind* = enum
    msgQuit

  Message* = object {.inheritable.}
  QuitMessage* = object of Message

  MessageQueue* = seq[ref Message]


var queue: MessageQueue = @[]


proc enqueue*(self: ref Message) =
  queue.add(self)

proc flush*() =
  queue.setLen(0)
