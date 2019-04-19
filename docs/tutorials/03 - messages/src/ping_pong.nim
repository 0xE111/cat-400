# ping_pong.nim
import c4/core
import c4/config

import systems/pinger
import systems/ponger


config.serverSystems["pinger"] = PingerSystem.new()
config.serverSystems["ponger"] = PongerSystem.new()

when isMainModule:
  core.run()
