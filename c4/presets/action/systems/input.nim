import sdl2.sdl
import strformat
import logging
import math

import ../../../config
import ../../../systems
import ../../../systems/input/sdl as input
import ../../../utils/stringify

import physics
import ../messages


type
  ActionInputSystem* = object of InputSystem


strMethod(ActionInputSystem, fields=false)


method handle*(self: ref ActionInputSystem, event: sdl.Event) =
  case event.kind
    of sdl.MOUSEMOTION:
      var x, y: cint
      discard sdl.getRelativeMouseState(x.addr, y.addr)
      (ref PlayerRotateMessage)(
        yaw: x.float32,
        pitch: y.float32,
      ).send(config.systems.video)

    of sdl.KEYDOWN:
      case event.key.keysym.sym
        # movement keys
        of K_w, K_s, K_a, K_d:
          var moveMessage = new(ref PlayerMoveMessage)

          case event.key.keysym.sym
            of K_w:
              moveMessage.yaw = PI / 2
            of K_s:
              moveMessage.yaw = 3 * PI / 2
            of K_a:
              moveMessage.yaw = PI
            of K_d:
              discard  # yaw == 0
            else:
              discard

          moveMessage.send(@[
            # config.systems.video,  # this message is sent directly to video system for client-side movement prediction
            config.systems.network,  # as well as to the server
          ])

        else:
          discard
    else:
      discard

  # fallback to default implementation
  procCall self.as(ref InputSystem).handle(event)
