import sdl2/sdl
import logging
import tables
import strformat
import unittest
import os

import ../../threads
import ../../messages
import ../../loop


type SdlInputSystem* {.inheritable.} = object

proc `$`*(event: Event): string = $event.kind


# ---- messages ----
type WindowResizeMessage* = object of Message
    width*, height*: int
register WindowResizeMessage

type WindowQuitMessage* = object of Message
register WindowQuitMessage


# ---- workflow methods ----
proc init*(self: var SdlInputSystem) =
  logging.debug("Initializing input system")

  try:
    if initSubSystem(INIT_EVENTS) != 0:
      raise newException(LibraryError, "Could not init SDL input subsystem" & $getError())

  except LibraryError:
    quitSubSystem(INIT_EVENTS)
    logging.fatal(getCurrentExceptionMsg())
    raise

proc handle*(self: SdlInputSystem, event: Event) =
  ## Handling of basic event. These are pretty reasonable defaults.
  case event.kind
    of QUIT:
      new(WindowQuitMessage).send("video")
    of WINDOWEVENT:
      case event.window.event
        of WINDOWEVENT_SIZE_CHANGED:
          (ref WindowResizeMessage)(
            width: event.window.data1,
            height: event.window.data2,
          ).send("video")
        else:
          discard
    else:
      discard

proc update*(self: SdlInputSystem, dt: float) =
  # process all network events
  var event = Event()

  while pollEvent(event.addr) != 0:
    self.handle(event)


proc dispose*(self: var SdlInputSystem) =
  quitSubSystem(INIT_EVENTS)  # TODO: destroying single SdlInputSystem will destroy events for all other InputSystems
  logging.debug "Input system destroyed"


method process*(self: SdlInputSystem, message: ref Message) {.base.} =
  logging.warn &"No rule for processing {message}"


proc run*(self: var SdlInputSystem) =
  self.init()

  loop(frequency=30) do:
    self.update(dt)
    while true:
      let message = tryRecv()
      if message.isNil:
        break
      self.process(message)
  do:
    discard

  self.dispose()


when isMainModule:
  suite "System tests":
    test "Running inside thread":
      spawn("thread") do:
        var system = SdlInputSystem()
        system.run()

      sleep 1000
