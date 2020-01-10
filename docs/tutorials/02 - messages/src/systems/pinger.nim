# systems/pinger.nim
import c4/systems

import ../messages


type PingerSystem* = object of System

method `$`*(self: ref PingerSystem): string =
  "PingerSystem"

method process(self: ref PingerSystem, message: ref PongMessage) =
  # send ``PingMessage`` with increased counter
  (ref PingMessage)(cnt: message.cnt + 1).send("ponger")
