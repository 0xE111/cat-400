# systems/ponger.nim
import c4/core
import c4/systems as systems_module


import ../messages


type PongerSystem* = object of System

method `$`*(self: ref PongerSystem): string =
  "PongerSystem"

method process(self: ref PongerSystem, message: ref PingMessage) =
  # send ``PongMessage`` with increased counter
  (ref PongMessage)(cnt: message.cnt + 1).send(systems["pinger"])

method process(self: ref PongerSystem, message: ref SystemReadyMessage) =
  # send first message
  (ref PongMessage)(cnt: 0).send(systems["pinger"])
