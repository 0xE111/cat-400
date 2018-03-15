from sdl2.sdl import nil
from logging import debug, fatal
from "../utils/loading" import load

load "core/messages"
load "systems/input"
load "systems/input/handler"


type
  EventCallback* = proc(event: sdl.Event): ref Message {.closure.}

var
  event = sdl.Event()  # temp var for "update" proc


proc init*() =
  logging.debug("Initializing SDL input system")
  
  try:
    if sdl.initSubSystem(sdl.INIT_EVENTS) != 0:
      raise newException(LibraryError, "Could not init SDL input subsystem" & $sdl.getError())

  except LibraryError:
    sdl.quitSubSystem(sdl.INIT_EVENTS)
    logging.fatal(getCurrentExceptionMsg())
    raise

proc update*() =
  while sdl.pollEvent(event.addr) != 0:
    discard handler.handle(event)

proc release*() =
  sdl.quitSubSystem(sdl.INIT_EVENTS)
