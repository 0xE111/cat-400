import sdl2.sdl

from c4.utils.helpers import importOrFallback
from logging import debug
from strformat import `&`

importOrFallback "systems/input"
importOrFallback "systems/messages"


proc handle*(event: Event): ref Message =
  case event.kind
    of sdl.QUIT:
      result = new Message
      result.kind = msgQuit
    else:
      discard
  
  if result != nil:
    logging.debug(&"Handled event {event} -> new message {result[]}")
