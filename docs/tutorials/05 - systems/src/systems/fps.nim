# systems/fps.nim
import c4/loop
import c4/systems
import c4/logging

# define new system
type FpsSystem* = object of System
  # with custom field
  i: int
  bestFps: int

method update*(self: ref FpsSystem, dt: float) =

  # calculate fps
  let fps = (1 / dt).int

  # update custom field
  if fps > self.bestFps:
    self.bestFps = fps

  # use c4's logging system to output message
  info "fps measured", value=fps, i=self.i

  inc self.i
  if self.i > 15:
    raise newException(BreakLoopException, "")
