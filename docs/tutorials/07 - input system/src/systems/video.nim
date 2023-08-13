import c4/systems/video/sdl
import c4/loop

import ../messages


type VideoSystem* = object of sdl.VideoSystem


method process*(self: ref VideoSystem, message: ref StopMessage) =
  raise newException(BreakLoopException, "")
