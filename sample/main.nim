import c4/[
  conf,
  core,
]

from systems.physics import CustomPhysics
from systems.input import CustomInputSystem


config.title = "Sample game"
config.version = "0.1"
config.systems.input.instance = new(ref CustomInputSystem)


when isMainModule:
  core.run()
