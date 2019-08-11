import logging
import sdl2/sdl, sdl2/sdl_syswm
from strformat import `&`

import ../../lib/bgfx/bgfx

from ../../systems import System, `as`, init, update
from ../../utils/stringify import strMethod


type
  VideoSystem* = object of System
    window: sdl.Window

  Video* {.inheritable.} = object


# let assetsDir = getAppDir() / "assets" / "video"

# ---- System ----
strMethod(VideoSystem, fields=false)

method init*(self: ref VideoSystem) =
  # ---- SDL ----
  logging.debug "Initializing SDL video system"

  try:
    if sdl.initSubSystem(sdl.INIT_VIDEO) != 0:
      raise newException(LibraryError, "Could not init SDL video subsystem")

    # var displayMode: sdl.DisplayMode
    # if sdl.getCurrentDisplayMode(0, displayMode.addr) != 0:
    #   raise newException(LibraryError, "Could not get current display mode: " & $sdl.getError())

    self.window = sdl.createWindow(
      &"Title",
      100,  # window.x,
      100,  # window.y,
      800,  # window.width,
      600,  # window.height,
      (sdl.WINDOW_SHOWN or sdl.WINDOW_OPENGL or sdl.WINDOW_RESIZABLE or sdl.WINDOW_FULLSCREEN_DESKTOP).uint32,
    )
    if self.window == nil:
      raise newException(LibraryError, "Could not create SDL window")

    # -- no need to call this when using bgfx --
    # if sdl.glCreateContext(self.window) == nil:
    #   raise newException(LibraryError, "Could not create SDL OpenGL context")

    if sdl.setRelativeMouseMode(true) != 0:
      raise newException(LibraryError, "Could not enable relative mouse mode")

  except LibraryError:
    logging.fatal getCurrentExceptionMsg() & ": " & $sdl.getError()
    sdl.quitSubSystem(sdl.INIT_VIDEO)
    raise

  logging.debug "SDL video system initialized"

  # ---- bgfx ----
  logging.debug "Initializing BGFX"

  # We need to set platform data in order to make bgfx work with SDL.
  # Credits to https://github.com/Halsys/nim-bgfx/blob/master/examples/sdl_platform.nim
  # and https://gist.github.com/zlash/abf8d4bc2efb795a02361e4820a2da10

  # populate info
  var info: sdl_syswm.SysWMinfo
  sdl.version(info.version)
  assert sdl_syswm.getWindowWMInfo(self.window, info.addr)

  # ---- init bgfx ----
  raise newException(LibraryError, "BGFX graphics engine support is not implemented")

  # var bgfxConfig = bgfx.init_t()
  # bgfx.init_ctor(bgfxConfig.addr)

  # # TODO: rewrite it, currently too ugly
  # when defined(SDL_VIDEO_DRIVER_WINDOWS):
  #   bgfxConfig.platformData.nwh = cast[pointer](info.info.win.window)
  #   bgfxConfig.platformData.ndt = nil

  # elif defined(SDL_VIDEO_DRIVER_X11):
  #   bgfxConfig.platformData.nwh = cast[pointer](info.info.x11.window)
  #   bgfxConfig.platformData.ndt = cast[pointer](info.info.x11.display)

  # elif defined(SDL_VIDEO_DRIVER_COCOA):
  #   bgfxConfig.platformData.nwh = cast[pointer](info.info.cocoa.window)
  #   bgfxConfig.platformData.ndt = nil

  # else:
  #   logging.error "SDL video driver undefined"

  # bgfxConfig.platformData.backBuffer = nil
  # bgfxConfig.platformData.backBufferDS = nil
  # bgfxConfig.platformData.context = nil

  # discard bgfx.frame(false)
  # if not bgfx.init(bgfxConfig.addr):
  #   sdl.quitSubSystem(sdl.INIT_VIDEO)
  #   raise newException(LibraryError, "Could not initialize BGFX")

  # bgfx.reset(
  #   width=window.width.uint32,
  #   height=window.height.uint32,
  #   flags=bgfx.RESET_NONE,  # bgfx.RESET_VSYNC,
  #   format=bgfxConfig.resolution.format,
  # )

  # bgfx.set_debug(bgfx.DEBUG_TEXT)

  # bgfx.set_view_clear(
  #   id=0,
  #   flags=bgfx.CLEAR_COLOR or bgfx.CLEAR_DEPTH,
  #   rgba=uint32(0x303030f),
  #   depth=1.0,
  #   stencil=0.uint8,
  # )

  # bgfx.dbg_text_printf(0, 1, 0x0f, "BGFX debug text")

  # logging.debug "BGFX initialized"

  # procCall self.as(ref System).init()

method update*(self: ref VideoSystem, dt: float) =
  procCall self.as(ref System).update(dt)

  raise newException(LibraryError, "Not implemented")

proc `=destroy`*(self: var VideoSystem) =
  bgfx.shutdown()
  sdl.quitSubSystem(sdl.INIT_VIDEO)
  logging.debug "Video system unloaded"

method attach*(self: ref Video) {.base.} =
  raise newException(LibraryError, &"{$self.type}.init() not implemented")
