import sdl2.sdl
import logging
from "../utils/helpers" import importOrFallback

importOrFallback "systems/messages"

export sdl  # required for setting callback in config file


type
  EventCallback* = proc(event: sdl.Event): ref Message {.closure.}

var
  event = sdl.Event()  # temp var for "update" proc
  callback: EventCallback = proc(event: Event): ref Message = discard


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
    discard callback(event)

proc release*() =
  sdl.quitSubSystem(sdl.INIT_EVENTS)
