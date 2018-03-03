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
  if sdl.videoInit(nil) != 0:
    let err = "Could not init SDL video subsystem: " & $sdl.getError()

    sdl.videoQuit()
    logging.fatal(err)
    raise newException(LibraryError, err)

  self.window = sdl.createWindow(title.cstring, window.x.cint, window.y.cint, window.width.cint, window.height.cint, sdl.WINDOW_SHOWN)
  if self.window == nil:
    let err = "Could not create SDL window: " & $sdl.getError()

    sdl.videoQuit()
    logging.fatal(err)
    raise newException(LibraryError, err)

  logging.debug("SDL video system initialized")

{.experimental.}
proc `=destroy`*(self: var Video) =
  sdl.videoQuit()
  logging.debug("SDL video system destroyed")
