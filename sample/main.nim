import c4.core
from c4.conf import config
from systems.input_config import handleInput
import os


config.title = "Sample game"
config.version = "0.1"
config.input.eventCallback = handleInput

when isMainModule:
  run()
