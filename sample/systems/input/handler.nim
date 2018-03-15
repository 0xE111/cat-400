import sdl2.sdl

from c4.utils.loading import load
from logging import debug
from strformat import `&`

load "systems/input"
load "core/messages"


proc handle*(event: Event): ref Message =
  case event.kind
    of sdl.QUIT:
      result = new Message
      result.kind = msgQuit
    else:
      discard
  
  if result != nil:
    logging.debug(&"Handled event {event} -> new message {result[]}")
