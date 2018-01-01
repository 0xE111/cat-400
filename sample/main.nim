from c4.core import run
from c4.config import Config

const
  conf: Config = (version: "0.1")

from c4.utils.classes import State
from c4.server import Loading
echo("New switch reached")
method switch*(fromState: ref State, toState: ref Loading) =
  echo("Loading server...")


when isMainModule:
  run(conf)
