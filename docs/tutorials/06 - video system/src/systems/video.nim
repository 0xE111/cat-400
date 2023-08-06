import std/times
import math

import c4/logging
import c4/systems/video/sdl


type VideoSystem* = object of SdlVideoSystem


method update*(self: ref SdlVideoSystem, dt: float) =
  if self.renderer.renderClear() != 0: handleError("failed to clear renderer")

  var w, h: cint
  self.window.getWindowSize(w.addr, h.addr)
  let rectSize = int(400 * abs(sin(16 * cpuTime())))
  var rectangle = Rect(x: int(w/2-rectSize/2), y: int(h/2-rectSize/2), w: rectSize, h: rectSize)
  if setRenderDrawColor(self.renderer, 255.uint8, 255, 255, 255) != 0: handleError("failed to set renderer draw color")
  if sdl.renderDrawRect(self.renderer, rectangle.addr) != 0: handleError("failed to draw rectangle")

  if setRenderDrawColor(self.renderer, 0, 0, 0, 255) != 0: handleError("failed to set renderer draw color")
  self.renderer.renderPresent()
