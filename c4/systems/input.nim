from sdl2.sdl import nil
from logging import debug, fatal
from strformat import `&`
from "../utils/loading" import load

load "core/messages"


type
  InputSystem* = object {.inheritable.}


var
  tmpEvent = sdl.Event()
  tmpMessage: ref Message


method init*(input: ref InputSystem) {.base.} =
  logging.debug("Initializing input system")

  try:
    if sdl.initSubSystem(sdl.INIT_EVENTS) != 0:
      raise newException(LibraryError, "Could not init SDL input subsystem" & $sdl.getError())

  except LibraryError:
    sdl.quitSubSystem(sdl.INIT_EVENTS)
    logging.fatal(getCurrentExceptionMsg())
    raise

method handle*(input: ref InputSystem, event: sdl.Event): ref Message {.base.} =
  case event.kind
    of sdl.QUIT:
      result = new Message
      result.kind = msgQuit
    else:
      discard

  if result != nil:
    logging.debug(&"Handled event {event} -> new message {result[]}")

method update*(input: ref InputSystem, dt: float) {.base.} =
  while sdl.pollEvent(tmpEvent.addr) != 0:
    tmpMessage = input.handle(tmpEvent)
    if tmpMessage != nil:
      messages.queue.add(tmpMessage)

method `=destroy`*(input: ref InputSystem) {.base.} =
  sdl.quitSubSystem(sdl.INIT_EVENTS)
  logging.debug("Input system destroyed")
