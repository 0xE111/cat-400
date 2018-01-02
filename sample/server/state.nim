from c4.utils.states import State, None, switch  # import "switch" which will act like a forward declaration and suppress linter errors
from c4.server import Loading, Running
from logging import nil


method switch*(fr: ref None, to: ref Loading): ref State =
  logging.debug("Loading assets, building world")
  result = to.switch(new(ref Running))  # after resource loading switch from Loading to Intro

method switch*(fr: ref Loading, to: ref Running): ref State =
  logging.debug("Running our awesome game")
  result = to.switch(new(ref None))  # after running the game, switch to None which means exit

method switch*(fr: ref Running, to: ref None): ref State =
  logging.debug("Moving to final state")
  result = to  # just switch to None
