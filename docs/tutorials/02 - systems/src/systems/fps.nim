# systems/fps.nim
import logging
import strformat

import c4/systems

# define new system
type FpsSystem* = object of System
  # with custom field
  worstFps: int


method init(self: ref FpsSystem) =
  # don't forget to call this, or internal system's structures won't be initialized
  procCall self.as(ref System).init()

  # now init custom fields
  self.worstFps = 0

method update(self: ref FpsSystem, dt: float) =
  # call parent's method, which will process messages
  procCall self.as(ref System).update(dt)

  # calculate fps
  let fps = (1 / dt).int

  # update custom field
  if fps > self.worstFps:
    self.worstFps = fps

  # use c4's logging system to output message
  logging.debug &"FPS: {$fps}"
