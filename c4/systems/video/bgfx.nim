# ================== WARNING ================== #
#         This module is unmaintained           #
# ============================================= #
import logging
import strformat

import sdl2/sdl, sdl2/sdl_syswm

import ../../lib/bgfx/bgfx


type
  BgfxVideoSystem* = object
    window: Window

  Video* {.inheritable.} = object


# let assetsDir = getAppDir() / "assets" / "video"

# ---- System ----
proc init*(self: var BgfxVideoSystem) =
  # ---- SDL ----
  logging.debug "Initializing SDL video system"

  try:
    if initSubSystem(INIT_VIDEO) != 0:
      raise newException(LibraryError, "Could not init SDL video subsystem")

    # var displayMode: DisplayMode
    # if getCurrentDisplayMode(0, displayMode.addr) != 0:
    #   raise newException(LibraryError, "Could not get current display mode: " & $getError())

    self.window = createWindow(
      &"Title",
      100,  # window.x,
      100,  # window.y,
      800,  # window.width,
      600,  # window.height,
      (WINDOW_SHOWN or WINDOW_OPENGL or WINDOW_RESIZABLE or WINDOW_FULLSCREEN_DESKTOP).uint32,
    )
    if self.window == nil:
      raise newException(LibraryError, "Could not create SDL window")

    # -- no need to call this when using bgfx --
    # if glCreateContext(self.window) == nil:
    #   raise newException(LibraryError, "Could not create SDL OpenGL context")

    if setRelativeMouseMode(true) != 0:
      raise newException(LibraryError, "Could not enable relative mouse mode")

  except LibraryError:
    logging.fatal getCurrentExceptionMsg() & ": " & $getError()
    quitSubSystem(INIT_VIDEO)
    raise

  logging.debug "SDL video system initialized"

  # ---- bgfx ----
  logging.debug "Initializing BGFX"

  # We need to set platform data in order to make bgfx work with SDL.
  # Credits to https://github.com/Halsys/nim-bgfx/blob/master/examples/sdl_platform.nim
  # and https://gist.github.com/zlash/abf8d4bc2efb795a02361e4820a2da10

  # populate info
  var info: sdl_syswm.SysWMinfo
  version(info.version)
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
  #   quitSubSystem(INIT_VIDEO)
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
