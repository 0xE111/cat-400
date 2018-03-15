type
    MessageKind* = enum
      msgQuit
  
    Message* = object
      case kind*: MessageKind  # TODO: should I leave this accessible
        of msgQuit:
          discard
