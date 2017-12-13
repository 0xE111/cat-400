from c4.main import run
from c4.config import Config


const
  conf: Config = (version: "0.1")

when isMainModule:
  run(conf)
