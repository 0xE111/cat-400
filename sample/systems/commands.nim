type
  CommandKind* = enum
    cmdQuit

  Command* = object
    case kind*: CommandKind  # TODO: should I leave this accessible
      of cmdQuit:
        discard

var commandQueue*: seq[Command] = @[]

proc flushQueue*() =
  commandQueue = @[]
