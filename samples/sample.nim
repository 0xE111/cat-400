from c4.main import run
from c4.config import Config
from c4.utils import getVersion


const
  conf: Config = (version: getVersion())

when isMainModule:
  run(conf)
