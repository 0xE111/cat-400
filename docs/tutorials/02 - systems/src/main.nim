# main.nim
import c4/core
import c4/config

import systems/fps


config.serverSystems["fps"] = FpsSystem.new()

when isMainModule:
  core.run()
