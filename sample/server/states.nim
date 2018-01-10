import c4.utils.state
import c4.server
from logging import nil


method switch*(self: var ref State, newState: ref Loading, instance: ref Server) =
  if self of ref None:
    self = newState
    logging.debug("Custom loading")
    self.switch(new(ref Running), instance=instance)
