import strformat

import sdl2/sdl

import c4/systems
import c4/logging
import c4/messages

logScope:
  system = "SdlVideoSystem"

type
  SdlVideoSystem* = object of System
    window: sdl.Window
    renderer: sdl.Renderer

  SdlVideoSystemError * = object of LibraryError

  SdlVideoInitMessage* = object of Message
    windowTitle*: string
    windowX*: int
    windowY*: int
    windowWidth*: int
    windowHeight*: int
    flags*: uint32

  SdlVideoDrawRectangleMessage* = object of Message
    x*: int
    y*: int
    width*: int
    height*: int
    color*: array[4, uint8]


template handleError(message: string) =
  let error = sdl.getError()
  fatal message, error
  raise newException(SdlVideoSystemError, message & ": "  & $error)


method process*(self: ref SdlVideoSystem, message: ref SdlVideoInitMessage) =
  debug "initializing video"
  if sdl.initSubSystem(sdl.INIT_VIDEO) != 0: handleError("failed to initialize video")
  debug "initialized video"

  debug "creating window"
  self.window = sdl.createWindow(
    message.windowTitle.cstring,
    message.windowX,
    message.windowY,
    message.windowWidth,
    message.windowHeight,
    message.flags,
  )
  if self.window.isNil: handleError("failed to create window")
  debug "created window"

  debug "creating renderer"
  self.renderer = self.window.createRenderer(-1, sdl.RENDERER_ACCELERATED)
  if self.renderer.isNil: handleError("failed to create renderer")
  debug "created renderer"


method update*(self: ref SdlVideoSystem, dt: float) =
  if self.renderer.renderClear() != 0: handleError("failed to clear renderer")
  if setRenderDrawColor(self.renderer, 0, 0, 0, 255) != 0: handleError("failed to set renderer draw color")
  self.renderer.renderPresent()
