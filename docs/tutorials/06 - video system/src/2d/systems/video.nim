import std/times
import math

import sdl2

import c4/logging
import c4/systems/video/sdl


type VideoSystem* = object of sdl.VideoSystem


method update*(self: ref VideoSystem, dt: float) =
  if self.renderer.clear() != 0: handleError("failed to clear renderer")

  let windowSize = self.window.getSize()
  let rectSize = int(400 * abs(sin(epochTime())))
  var rectangle = rect(
    x=(windowSize.x/2-rectSize/2).cint,
    y=(windowSize.y/2-rectSize/2).cint,
    w=rectSize.cint,
    h=rectSize.cint,
  )
  if self.renderer.setDrawColor(255, 255, 255, 255) != SdlSuccess: handleError("failed to set renderer draw color")
  if self.renderer.drawRect(rectangle.addr) != SdlSuccess: handleError("failed to draw rectangle")

  if self.renderer.setDrawColor(0, 0, 0, 255) != SdlSuccess: handleError("failed to set renderer draw color")
  self.renderer.present()
