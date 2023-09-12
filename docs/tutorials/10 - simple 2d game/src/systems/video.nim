import sdl2

import c4/logging
import c4/entities
import c4/systems/video/sdl


type
  VideoSystem* = object of sdl.VideoSystem
  Video* = object of RootObj
    x*, y*: float
    width*, height*: float

proc topLeft(self: ref Video): tuple[x: float, y: float] =
  (self.x - self.width/2, self.y - self.height/2)

method update*(self: ref VideoSystem, dt: float) =
  if self.renderer.setDrawColor(0, 0, 0, 255) != SdlSuccess: handleError("failed to set renderer draw color")
  if self.renderer.clear() != 0: handleError("failed to clear renderer")

  if self.renderer.setDrawColor(255, 255, 255, 255) != SdlSuccess: handleError("failed to set renderer draw color")

  for video in getComponents(ref Video).values():

    let (x, y) = video.topLeft()
    var rectangle = rect(
      x=x.cint,
      y=y.cint,
      w=video.width.cint,
      h=video.height.cint,
    )
    if self.renderer.drawRect(rectangle.addr) != SdlSuccess: handleError("failed to draw rectangle")

  self.renderer.present()