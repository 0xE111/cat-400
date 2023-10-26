import sdl2
import math

import c4/logging
import c4/threads
import c4/systems/input/sdl
import c4/sugar

import ../messages
import ../threads


type
  InputSystem* = object of sdl.InputSystem


method handleEvent*(self: ref InputSystem, event: Event) =
  procCall self.as(ref sdl.InputSystem).handleEvent(event)

  case event.kind
    of MOUSEMOTION:
      var x, y: cint
      let radInPixel = PI / 180 / 4  # 0.25 degree in 1 pixel
      discard getRelativeMouseState(x, y)
      trace "mouse moved", x, y
      (ref PlayerRotateMessage)(
        yaw: -x.float * radInPixel,
        pitch: -y.float * radInPixel,
      ).send(networkThread)
    else:
      discard


# method handleKeyboardState*(
#   self: ref InputSystem,
#   keyboard: ptr array[0 .. SDL_NUM_SCANCODES.int, uint8],
# ) =


#   var direction = 0
#   if keyboard[SDL_SCANCODE_UP.int] > 0: direction += 1
#   if keyboard[SDL_SCANCODE_DOWN.int] > 0: direction -= 1

#   case direction:
#     of 1:
#       (ref MoveMessage)(up: true).send(networkThread)
#     of -1:
#       (ref MoveMessage)(up: false).send(networkThread)
#     else:
#       discard

#   # if keys.len > 0:
#   #   info "keyboard input", keys

#   # if keyboard[SDL_SCANCODE_ESCAPE.int] > 0:
#   #   new(StopMessage).send(c4threads.ThreadID(1))
#   #   info "quit"
#   #   raise newException(BreakLoopException, "")
