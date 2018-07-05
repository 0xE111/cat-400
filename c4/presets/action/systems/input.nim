import sdl2.sdl
import strformat
import logging

import "../../../config"
import "../../../systems"
import "../../../systems/input/sdl" as input

import physics
import "../messages"


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
          var
            x = 0.0
            y = 0.0
            z = 0.0

          case event.key.keysym.sym
            of K_w:
              z = -1.0
            of K_s:
              z = 1.0
            of K_a:
              x = -1.0
            of K_d:
              x = 1.0
            else:
              discard
            
          (ref MoveMessage)(
            x: x, y: y, z: z,
          ).send(@[
            # config.systems.video,  # this message is sent directly to video system for client-side movement prediction
            config.systems.network,  # as well as to the server
          ])
          
        else:
          discard
    else:
      discard
    
  # fallback to default implementation
  procCall self.as(ref InputSystem).handle(event)
