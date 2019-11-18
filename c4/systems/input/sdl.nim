import sdl2/sdl
import logging
import tables
import strformat

import ../../services
import ../../messages
import ../../utils/loop


type InputSystem* = object of Service

proc `$`*(event: sdl.Event): string = $event.kind


# ---- messages ----
type WindowResizeMessage* = object of Message
    width*, height*: int
messages.register(WindowResizeMessage)

type WindowQuitMessage* = object of Message
messages.register(WindowQuitMessage)


# ---- workflow methods ----
proc init*(self: InputSystem) =
  logging.debug("Initializing input system")

  try:
    if sdl.initSubSystem(sdl.INIT_EVENTS) != 0:
      raise newException(LibraryError, "Could not init SDL input subsystem" & $sdl.getError())

  except LibraryError:
    sdl.quitSubSystem(sdl.INIT_EVENTS)
    logging.fatal(getCurrentExceptionMsg())
    raise

proc handle*(self: InputSystem, event: sdl.Event) =
  ## Handling of basic sdl event. These are pretty reasonable defaults.
  case event.kind
    of sdl.QUIT:
      new(WindowQuitMessage).send("video")
    of sdl.WINDOWEVENT:
      case event.window.event
        of sdl.WINDOWEVENT_SIZE_CHANGED:
          (ref WindowResizeMessage)(
            width: event.window.data1,
            height: event.window.data2,
          ).send("video")
        else:
          discard
    else:
      discard

proc poll*(self: InputSystem, dt: float) =
  # process all network events
  var event {.global.} = sdl.Event()

  while sdl.pollEvent(event.addr) != 0:
    self.handle(event)


proc `=destroy`*(self: var InputSystem) =
  sdl.quitSubSystem(sdl.INIT_EVENTS)  # TODO: destroying single InputSystem will destroy sdl events for all other InputSystems
  logging.debug "Input system destroyed"


method process*(self: InputSystem, message: ref Message) {.base.} =
  logging.warn &"No rule for processing {message}"


proc run*(self: InputSystem) =
  self.init()

  runLoop(
    updatesPerSecond=30,
    fixedFrequencyCallback=
      proc(dt: float): bool =
        self.poll(dt)
        true,
    maxFrequencyCallback=
      proc(dt: float): bool =
        let message = self.tryRecv()
        if not message.isNil:
          self.process(message)
        true,
  )
