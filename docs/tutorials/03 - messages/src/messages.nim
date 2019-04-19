# messages.nim
import strformat

import c4/core/messages


type
  PingMessage* = object of Message
    cnt*: int

  PongMessage* = object of Message
    cnt*: int

method `$`*(self: ref PingMessage): string =
  &"PingMessage ({self.cnt})"

method `$`*(self: ref PongMessage): string =
  &"PongMessage ({self.cnt})"
