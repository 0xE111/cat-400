import sdl2/sdl
import logging
import tables
import strformat
import unittest
import os
import typetraits

import ../../threads
import ../../messages
import ../../loop


type SdlInputSystem* {.inheritable.} = object
  event: Event  # temporary storage for event when calling pollEvent()

proc `$`*(event: Event): string = $event.kind


# ---- messages ----
type WindowResizeMessage* = object of Message
    width*, height*: int
register WindowResizeMessage

type WindowQuitMessage* = object of Message
register WindowQuitMessage


# ---- workflow methods ----
method init*(self: ref SdlInputSystem) {.base.} =
  logging.debug &"Initializing {self[].type.name}"

  try:
    if wasInit(INIT_VIDEO) == 0:
      # INIT_VIDEO implies INIT_EVENTS -> don't initialize events if video already initialized
      logging.debug "Initializing SDL events"
      if initSubSystem(INIT_EVENTS) != 0:
        raise newException(LibraryError, &"Could not init {self.type.name}: {getError()}")

  except LibraryError:
    quitSubSystem(INIT_EVENTS)
    logging.fatal(getCurrentExceptionMsg())
    raise

method handle*(self: ref SdlInputSystem, event: Event) {.base.} =
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
    # of KEYDOWN:
    #   case event.key.keysym.sym
    #     of K_c:
    #       ...
    else:
      discard

method handle*(self: ref SdlInputSystem, keyboard: ptr array[NUM_SCANCODES.int, uint8]) {.base.} =
  discard

method update*(self: ref SdlInputSystem, dt: float) {.base.} =
  while pollEvent(self.event.unsafeAddr) != 0:
    self.handle(self.event)

  self.handle(getKeyboardState(nil))

method dispose*(self: ref SdlInputSystem) {.base.} =
  quitSubSystem(INIT_EVENTS)
  logging.debug &"{self.type.name} destroyed"


method process*(self: ref SdlInputSystem, message: ref Message) {.base.} =
  logging.warn &"No rule for processing {message}"


method run*(self: ref SdlInputSystem) {.base.} =
  loop(frequency=30) do:
    self.update(dt)
    while true:
      let message = tryRecv()
      if message.isNil:
        break
      self.process(message)


when isMainModule:
  suite "System tests":
    test "Running inside thread":
      spawn("thread") do:
        let system = new(SdlInputSystem)
        system.init()
        system.run()
        system.dispose()

      sleep 1000
