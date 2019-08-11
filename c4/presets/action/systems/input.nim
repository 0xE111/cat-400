import sdl2/sdl
import math
import tables

import ../../../core
import ../../../systems as systems_module
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
      let radInPixel = PI / 180 / 4  # 0.25 degree in 1 pixel
      discard sdl.getRelativeMouseState(x.addr, y.addr)
      (ref PlayerRotateMessage)(
        yaw: -x.float * radInPixel,
        pitch: -y.float * radInPixel,
      ).send(@[
        systems["network"],
        # systems["video"],  # client-side prediction
      ])

    of sdl.KEYDOWN:
      case event.key.keysym.sym
        # movement keys
        of K_w, K_s, K_a, K_d:
          var moveMessage = new(ref PlayerMoveMessage)

          case event.key.keysym.sym
            of K_w:
              moveMessage.yaw = 0
            of K_s:
              moveMessage.yaw = PI
            of K_a:
              moveMessage.yaw = PI / 2
            of K_d:
              moveMessage.yaw = -PI / 2
            else:
              discard

          moveMessage.send(systems["network"])

        else:
          discard
    else:
      discard

  # fallback to default implementation
  procCall self.as(ref InputSystem).handle(event)
