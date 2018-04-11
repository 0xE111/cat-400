from sdl2.sdl import nil
from logging import debug, fatal
from strformat import `&`
import "../systems"
import "../core/messages"
import "../config"
import "../defaults/messages" as default_messages


type
  InputSystem* = object of System


var
  event = sdl.Event()
  message: ref Message


proc `$`*(event: sdl.Event): string = $event.kind


# ---- message handling ----
method process*(self: ref InputSystem, message: ref QuitMessage) =
  logging.debug("Input processing Quit message")

# ---- workflow methods ----
method init*(self: ref InputSystem) =
  logging.debug("Initializing input system")

  try:
    if sdl.initSubSystem(sdl.INIT_EVENTS) != 0:
      raise newException(LibraryError, "Could not init SDL input subsystem" & $sdl.getError())

  except LibraryError:
    sdl.quitSubSystem(sdl.INIT_EVENTS)
    logging.fatal(getCurrentExceptionMsg())
    raise
  
  procCall ((ref System)self).init()

method handle*(self: ref InputSystem, event: sdl.Event) {.base.} =
  case event.kind
    of sdl.QUIT:  # TODO: move to defaults?
      new(QuitMessage).send(@[
        config.systems.video,
        config.systems.network,
      ])
    else:
      discard

method update*(self: ref InputSystem, dt: float) =
  # process all network events
  while sdl.pollEvent(event.addr) != 0:
    self.handle(event)

  procCall ((ref System)self).update(dt)  # TODO: maybe avoid using procCall, just put message handling in proc other than `update`

{.experimental.}
method `=destroy`*(self: ref InputSystem) {.base.} =
  sdl.quitSubSystem(sdl.INIT_EVENTS)  # TODO: destroying single InputSystem will destroy sdl events for all other InputSystems
  logging.debug("Input system destroyed")
