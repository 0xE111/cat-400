from c4.utils.states import State
from c4.server import Loading


method switch*(fr: ref State, to: ref Loading): ref State =
  echo("Custom switch")
  result = to
