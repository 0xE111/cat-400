from c4.core import run
from c4.conf import config


config.title = "Sample game"
config.version = "0.1"


when isMainModule:
  run()
