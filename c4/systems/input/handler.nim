from c4.utils.helpers import importOrFallback

from sdl2.sdl import Event
importOrFallback "systems/messages"


proc handle*(event: Event): ref Message =
  discard
