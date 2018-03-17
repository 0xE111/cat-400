type
  MessageKind* = enum
    msgQuit

  Message* = object
    case kind*: MessageKind
      of msgQuit:
        discard

  MessageQueue* = seq[ref Message]
        

var queue*: MessageQueue = @[]

proc flush*(queue: var MessageQueue) =
  queue.setLen(0)
