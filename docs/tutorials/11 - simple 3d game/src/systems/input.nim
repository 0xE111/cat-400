import sdl2
import math

import c4/loop
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


method handleKeyboardState*(
  self: ref InputSystem,
  keyboard: ptr array[0 .. SDL_NUM_SCANCODES.int, uint8],
) =
  var
    forward = keyboard[SDL_SCANCODE_W.int] > 0
    backward = keyboard[SDL_SCANCODE_S.int] > 0
    left = keyboard[SDL_SCANCODE_A.int] > 0
    right = keyboard[SDL_SCANCODE_D.int] > 0

  # pressing opposite keys disables both of them
  if forward and backward:
    forward = false
    backward = false

  if left and right:
    left = false
    right = false

  if forward or backward or left or right:
    var yaw: float
    if right and not forward and not backward:
      yaw = -2 * PI/4
    elif right and forward:
      yaw = -1 * PI/4
    elif forward and not right and not left:
      yaw = 0 * PI/4
    elif forward and left:
      yaw = 1 * PI/4
    elif left and not forward and not backward:
      yaw = 2 * PI/4
    elif left and backward:
      yaw = 3 * PI/4
    elif backward and not left and not right:
      yaw = 4 * PI/4
    elif backward and right:
      yaw = 5 * PI/4

    (ref PlayerMoveMessage)(yaw: yaw).send(networkThread)

  # if keyboard[SDL_SCANCODE_ESCAPE.int] > 0:
  #   raise newException(BreakLoopException, "")
  let
    up = keyboard[SDL_SCANCODE_SPACE.int] > 0
    down = keyboard[SDL_SCANCODE_LCTRL.int] > 0
  if up or down and not (up and down):
    (ref PlayerVerticalMoveMessage)(up: up).send(networkThread)
