import strformat

import sdl2

import ../../systems
import ../../logging
import ../../messages

type
  VideoSystem* = object of System
    window*: WindowPtr
    renderer*: RendererPtr

  VideoSystemError* = object of LibraryError

  VideoInitMessage* = object of Message
    windowTitle*: string
    windowX*: cint
    windowY*: cint
    windowWidth*: cint
    windowHeight*: cint
    flags*: uint32

VideoInitMessage.register()


template handleError*(message: string) =
  let error = getError()
  fatal message, error
  raise newException(VideoSystemError, message & ": "  & $error)


method process*(self: ref VideoSystem, message: ref VideoInitMessage) =
  withLog(DEBUG, "initializing video"):
    if initSubSystem(INIT_VIDEO) != 0: handleError("failed to initialize video")

  withLog(DEBUG, "creating window"):
    self.window = createWindow(
      title=message.windowTitle.cstring,
      x=message.windowX,
      y=message.windowY,
      w=message.windowWidth,
      h=message.windowHeight,
      flags=message.flags,
    )
    if self.window.isNil: handleError("failed to create window")

  withLog(DEBUG, "creating renderer"):
    self.renderer = self.window.createRenderer(-1, RENDERER_ACCELERATED)
    if self.renderer.isNil: handleError("failed to create renderer")


method update*(self: ref VideoSystem, dt: float) =
  if self.renderer.clear() != 0: handleError("failed to clear renderer")
  if self.renderer.setDrawColor(0, 0, 0, 255) != SdlSuccess: handleError("failed to set renderer draw color")
  self.renderer.present()


method dispose*(self: ref VideoSystem) =
  self.renderer.destroyRenderer()
  self.window.destroyWindow()
  quitSubSystem(INIT_VIDEO)
  debug "disposed video system"
