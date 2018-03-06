import sdl2.sdl
import logging

export sdl.Event  # required for setting callback in config file


type
  EventCallback* = proc(event: sdl.Event) {.closure.}

var
  event: sdl.Event
  callback: EventCallback


proc init*(eventCallback: EventCallback) =
  logging.debug("Initializing SDL input system")
  
  try:
    if sdl.initSubSystem(sdl.INIT_EVENTS) != 0:
      raise newException(LibraryError, "Could not init SDL input subsystem" & $sdl.getError())
  
    callback = eventCallback

  except LibraryError:
    sdl.quitSubSystem(sdl.INIT_EVENTS)
    logging.fatal(getCurrentExceptionMsg())
    raise

proc update*() =
  while sdl.pollEvent(event.addr) != 0:
    event.callback()

proc release*() =
  sdl.quitSubSystem(sdl.INIT_EVENTS)
