import sdl2.sdl
import logging
import msgpack4nim

import c4.client
import c4.systems.input
import c4.systems.network

import commands


proc handleInput*(event: Event) =
  case event.kind
    of sdl.QUIT:
      var command = Command(kind: cmdQuit)
      commandQueue.add(command)
      network.send(data=command.pack(), reliable=true)
    else:
      discard
