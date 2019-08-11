# systems/pinger.nim
import c4/core
import c4/systems as systems_module


import ../messages


type PingerSystem* = object of System

method `$`*(self: ref PingerSystem): string =
  "PingerSystem"

method process(self: ref PingerSystem, message: ref PongMessage) =
  # send ``PingMessage`` with increased counter
  (ref PingMessage)(cnt: message.cnt + 1).send(systems["ponger"])
