from c4.main import run
from c4.config import Config

when isMainModule:
  const conf: Config = (version: "0.1")
  run(conf)
