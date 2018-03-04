import sdl2.sdl
import logging
from "../conf" import Window

type
  Video* = object
    window: sdl.Window


proc init*(
  self: var Video,
  title: string,
  window: conf.Window,
) =
  try:
    if sdl.videoInit(nil) != 0:
      raise newException(LibraryError, "Could not init SDL video subsystem: " & $sdl.getError())

    self.window = sdl.createWindow(
      title.cstring,
      window.x.cint,
      window.y.cint,
      window.width.cint,
      window.height.cint,
      sdl.WINDOW_SHOWN or sdl.WINDOW_OPENGL,
    )
    if self.window == nil:
      raise newException(LibraryError, "Could not create SDL window: " & $sdl.getError())

    if sdl.glCreateContext(self.window) == nil:
      raise newException(LibraryError, "Could not create SDL OpenGL context: " & $sdl.getError())

  except LibraryError:
    sdl.videoQuit()
    logging.fatal(getCurrentExceptionMsg())
    raise
    
  logging.debug("SDL video system initialized")



{.experimental.}
proc `=destroy`*(self: var Video) =
  sdl.videoQuit()
  logging.debug("SDL video system destroyed")
