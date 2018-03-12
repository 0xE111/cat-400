import sdl2.sdl
import logging
import msgpack4nim

import c4.client
import c4.systems.input
import c4.systems.network

import messages


proc handleInput*(event: Event): ref Message =
  case event.kind
    of sdl.QUIT:
      result = new Message
      result.kind = msgQuit
    else:
      discard
