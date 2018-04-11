import sdl2.sdl
from strformat import `&`
from logging import debug

import c4.core.messages
import c4.systems
import c4.config
import c4.systems.input
import "../core/messages" as custom_messages


type
  CustomInputSystem* = object of InputSystem


method handle(self: ref CustomInputSystem, event: sdl.Event) =
  case event.kind
    of sdl.KEYDOWN:
      case event.key.keysym.sym
        of sdl.K_c:
          new(ConnectMessage).send(config.systems.network)
        of sdl.K_l:
          new(LoadSceneMessage).send(config.systems.network)
        else:
          discard
    else:
      # fallback to default implementation
      procCall(((ref InputSystem)self).handle(event))
