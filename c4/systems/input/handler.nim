from c4.utils.loading import load
from sdl2.sdl import Event
load "core/messages"


proc handle*(event: Event): ref Message =
  discard
