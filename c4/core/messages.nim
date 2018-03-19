type
  MessageKind* = enum
    msgQuit

  Message* = object {.inheritable.}
    case kind*: MessageKind  # TODO: should I leave this accessible
      of msgQuit:
        discard

  MessageQueue* = seq[ref Message]


var queue*: MessageQueue = @[]


proc flush*(queue: var MessageQueue) =
  queue.setLen(0)
