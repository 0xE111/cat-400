import sdl2.sdl
import logging

import c4.client
import c4.systems.input
import c4.systems.network


proc handleInput*(event: Event) =
  case event.kind
    of sdl.QUIT:
      client.running = false
      logging.debug("App QUIT")
    else:
      discard
