from c4.utils.states import State, None, switch  # "import switch" will act like a forward declaration and suppress linter errors
from c4.server import Loading, Running
from logging import nil


method switch*(fr: ref None, to: ref Loading): ref State =
  logging.debug("Loading")
  result = to.switch(new(ref Running))

method switch*(fr: ref Loading, to: ref Running): ref State =
  logging.debug("Running")
  result = to.switch(new(ref None))

method switch*(fr: ref Running, to: ref None): ref State =
  result = to
