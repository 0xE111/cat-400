import strformat

import sdl2

import c4/systems
import c4/logging
import c4/messages

type
  SdlVideoSystem* = object of System
    window*: WindowPtr
    renderer*: RendererPtr

  SdlVideoSystemError* = object of LibraryError

  SdlVideoInitMessage* = object of Message
    windowTitle*: string
    windowX*: cint
    windowY*: cint
    windowWidth*: cint
    windowHeight*: cint
    flags*: uint32

SdlVideoInitMessage.register()


template handleError*(message: string) =
  let error = getError()
  fatal message, error
  raise newException(SdlVideoSystemError, message & ": "  & $error)


method process*(self: ref SdlVideoSystem, message: ref SdlVideoInitMessage) =
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


method update*(self: ref SdlVideoSystem, dt: float) =
  if self.renderer.clear() != 0: handleError("failed to clear renderer")
  if self.renderer.setDrawColor(0, 0, 0, 255) != SdlSuccess: handleError("failed to set renderer draw color")
  self.renderer.present()


method dispose*(self: ref SdlVideoSystem) =
  self.renderer.destroyRenderer()
  self.window.destroyWindow()
  quitSubSystem(INIT_VIDEO)
  debug "disposed video system"
