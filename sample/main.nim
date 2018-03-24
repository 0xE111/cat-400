from c4.core import run
from c4.conf import config
from systems.input import CustomInputSystem


config.title = "Sample game"
config.version = "0.1"
config.systems.input.instance = new(ref CustomInputSystem)


when isMainModule:
  run()
