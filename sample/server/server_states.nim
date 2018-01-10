import c4.utils.state
import c4.server
from logging import nil


method switch*(self: var ref State, newState: ref Running, instance: ref Server) =
  if self of ref Loading:
    self = newState  # actually swich current state to Running
    echo("Hello world")
