type
  MessageKind* = enum
    msgQuit

  Message* = object
    case kind*: MessageKind
      of msgQuit:
        discard
