from c4.core import run
from c4.conf import config
from systems.input_config import handleInput


config.title = "Sample game"
config.version = "0.1"
config.input.eventCallback = handleInput

when isMainModule:
  run()
