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
      let radInPixel = PI / 180 / 4  # 0.25 degree in 1 pixel
      discard sdl.getRelativeMouseState(x.addr, y.addr)
      (ref PlayerRotateMessage)(
        yaw: -x.float * radInPixel,
        pitch: -y.float * radInPixel,
      ).send(@[
        config.systems.network,
        # config.systems.video,  # client-side prediction
      ])

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

          raise newException(LibraryError, "Not implemented")
          # TODO: implement
          # moveMessage.send(self)

        else:
          discard
    else:
      discard

  # fallback to default implementation
  procCall self.as(ref InputSystem).handle(event)
