import logging
import strformat
import os

import sdl2/sdl

import c4/threads
import c4/messages
import c4/loop

when isMainModule:
  import unittest


type
  SdlVideoSystem* {.inheritable.} = object
    window: Window
    renderer: Renderer

  Video* {.inheritable.} = object
    x, y: int


proc init*(self: var SdlVideoSystem, windowTitle: string = "Game", windowX: int = 100, windowY: int = 100, windowWidth: int = 640, windowHeight: int = 480, fullscreen: bool = false) =

  logging.debug &"Initializing SdlVideoSystem"

  if initSubSystem(INIT_VIDEO) != 0:
    raise newException(LibraryError, &"Could not init SdlVideoSystem: {getError()}")

  # create window
  self.window = createWindow(windowTitle, windowX, windowY, windowWidth, windowHeight, (WINDOW_SHOWN or WINDOW_RESIZABLE or (if fullscreen: WINDOW_FULLSCREEN_DESKTOP else: 0)).uint32)

  # initialize renderer
  self.renderer = self.window.createRenderer(-1, RENDERER_ACCELERATED)
  if self.renderer.isNil:
    raise newException(LibraryError, &"Could not create renderer: {getError()}")

  if self.renderer.setRenderDrawColor(uint8.high, uint8.high, uint8.high, uint8.high) != 0:
    raise newException(LibraryError, &"Could not set renderer draw color: {getError()}")

  if self.renderer.renderClear() != 0:
    raise newException(LibraryError, &"Could not clear renderer: {getError()}")


method update*(self: var SdlVideoSystem, dt: float) {.base.} =
  if self.renderer.renderClear() != 0:
    raise newException(LibraryError, &"Could not clear renderer: {getError()}")
  self.renderer.renderPresent()


method process*(self: SdlVideoSystem, message: ref Message) {.base.} =
  logging.warn &"No rule for processing {message}"


proc dispose*(self: var SdlVideoSystem) =
  self.renderer.destroyRenderer()
  self.window.destroyWindow()
  quitSubSystem(INIT_VIDEO)
  logging.debug "SdlVideoSystem unloaded"


proc run*(self: var SdlVideoSystem) =
  loop(frequency=30) do:
    while true:
      let message = tryRecv()
      if message.isNil:
        break
      self.process(message)
    self.update(dt)
  do:
    discard


when isMainModule:
  suite "System tests":
    test "Running inside thread":
      spawn("thread") do:
        var system = SdlVideoSystem()
        system.init()
        system.run()
        system.dispose()

      sleep 2000
