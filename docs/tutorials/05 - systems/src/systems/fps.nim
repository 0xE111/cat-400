# systems/fps.nim
import strformat

import c4/loop

# define new system
type FpsSystem* = object  # just some object, no inheritance needed
  # with custom field
  worstFps: int


proc init*(self: var FpsSystem) =
  self.worstFps = 0

proc run*(self: var FpsSystem) =
  var i = 0
  loop(frequency=60):
    # calculate fps
    let fps = (1 / dt).int

    # update custom field
    if fps > self.worstFps:
      self.worstFps = fps

    # use c4's logging system to output message
    echo &"FPS: {$fps}"
    inc i
    if i > 100:
      break
