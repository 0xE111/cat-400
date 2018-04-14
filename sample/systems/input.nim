import sdl2.sdl
from strformat import `&`
from logging import debug

import c4.core.messages
import c4.systems
import c4.config
import c4.systems.input
import c4.defaults.messages as default_messages
import "../core/messages" as custom_messages


type
  CustomInputSystem* = object of InputSystem


method handle(self: ref CustomInputSystem, event: sdl.Event) =
  case event.kind
    of sdl.MOUSEMOTION:
      var x, y: cint
      discard sdl.getRelativeMouseState(x.addr, y.addr)
      (ref RotationMessage)(
        yaw: x.float32,
        pitch: y.float32,
      ).send(config.systems.video)

    of sdl.KEYDOWN:
      case event.key.keysym.sym
        of sdl.K_c:
          new(ConnectMessage).send(config.systems.network)

        of sdl.K_l:
          new(LoadSceneMessage).send(config.systems.network)

        of sdl.K_w:
          new(ForwardMessage).send(config.systems.video)

        of sdl.K_s:
          new(BackwardMessage).send(config.systems.video)
          
        else:
          discard
    else:
      discard
    
  # fallback to default implementation
  procCall(((ref InputSystem)self).handle(event))
