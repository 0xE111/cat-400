import tables

import c4/config
import c4/core

import systems/video

config.clientSystems.add("video", CustomVideoSystem.new())

when isMainModule:
  core.run()
