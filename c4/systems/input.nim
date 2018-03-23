from sdl2.sdl import nil
from logging import debug, fatal
from strformat import `&`
from "../core/messages" import Message, QuitMessage, subscribe, send, `$`


type
  InputSystem* = object {.inheritable.}


var
  tmpEvent = sdl.Event()
  tmpMessage: ref Message


proc `$`(event: sdl.Event): string = $event.kind


method onMessage*(self: ref InputSystem, message: ref Message) {.base.} =
  logging.debug(&"Input got new message: {message}")

method init*(self: ref InputSystem) {.base.} =
  logging.debug("Initializing input system")

  try:
    if sdl.initSubSystem(sdl.INIT_EVENTS) != 0:
      raise newException(LibraryError, "Could not init SDL input subsystem" & $sdl.getError())

  except LibraryError:
    sdl.quitSubSystem(sdl.INIT_EVENTS)
    logging.fatal(getCurrentExceptionMsg())
    raise
  
  messages.subscribe(proc (message: ref Message) = self.onMessage(message))

method handle*(self: ref InputSystem, event: sdl.Event): ref Message {.base.} =
  case event.kind
    of sdl.QUIT:
      result = new(ref QuitMessage)
    else:
      discard

  if result != nil:
    logging.debug(&"Handled event {event} -> new message {result}")

method update*(self: ref InputSystem, dt: float) {.base.} =
  while sdl.pollEvent(tmpEvent.addr) != 0:
    tmpMessage = self.handle(tmpEvent)
    if tmpMessage != nil:
      tmpMessage.send()

{.experimental.}
method `=destroy`*(self: ref InputSystem) {.base.} =
  sdl.quitSubSystem(sdl.INIT_EVENTS)  # TODO: destroying single InputSystem will destroy sdl events for all other InputSystems
  logging.debug("Input system destroyed")
