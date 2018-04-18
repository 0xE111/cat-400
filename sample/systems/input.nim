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
      (ref RotateMessage)(
        yaw: x.float32,
        pitch: y.float32,
      ).send(config.systems.video)

    of sdl.KEYDOWN:
      case event.key.keysym.sym
        # connect
        of sdl.K_c:
          new(ConnectMessage).send(config.systems.network)

        # load scene
        of sdl.K_l:
          new(LoadSceneMessage).send(config.systems.network)

        # movement keys
        of sdl.K_w, sdl.K_s:
          var message: ref Message

          case event.key.keysym.sym
            of sdl.K_w:
              message = new(MoveForwardMessage)
            of sdl.K_s:
              message = new(MoveBackwardMessage)
            else:
              discard
            
          message.send(@[
            config.systems.video,  # this message is sent directly to video system for client-side movement prediction
            config.systems.network,  # as well as to the server
          ])
          
        else:
          discard
    else:
      discard
    
  # fallback to default implementation
  procCall ((ref InputSystem)self).handle(event)
