import sdl2.sdl
import strformat
import logging

import "../../../config"
import "../../../core/messages"
import "../../../systems"
import "../../../systems/input/sdl" as input
import "../messages" as action_messages


type
  ActionInputSystem* = object of InputSystem


method handle*(self: ref ActionInputSystem, event: sdl.Event) =
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
        # movement keys
        of K_w, K_s, K_a, K_d:
          var message: ref Message

          case event.key.keysym.sym
            of K_w:
              message = new(MoveForwardMessage)
            of K_s:
              message = new(MoveBackwardMessage)
            of K_a:
              message = new(MoveLeftMessage)
            of K_d:
              message = new(MoveRightMessage)
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
