import sdl2/sdl as sdllib
import math

import c4/systems
import c4/systems/input/sdl
import c4/utils/stringify

import ../messages


type
  InputSystem* = object of sdl.InputSystem


strMethod(InputSystem, fields=false)


method handle*(self: ref InputSystem, event: Event) =
  case event.kind
    of WINDOWEVENT:
      case event.window.event
        of WINDOWEVENT_FOCUS_LOST:
          discard
          # self.state = State.inactive

        of WINDOWEVENT_TAKE_FOCUS:
          discard
          # self.state = State.active

        else:
          discard

    of MOUSEMOTION:
      var x, y: cint
      let radInPixel = PI / 180 / 4  # 0.25 degree in 1 pixel
      discard getRelativeMouseState(x.addr, y.addr)
      (ref PlayerRotateMessage)(
        yaw: -x.float * radInPixel,
        pitch: -y.float * radInPixel,
      ).send(@[
        "network",
        # systems.get("video"),  # client-side prediction
      ])

    # when some key is held down, there's usually a delay between first sdl.KEYDOWN event
    # and subsequent ones; so if you want to send some messages constantly when key is pressed
    # (for example, `PlayerMoveMessage`), you shouldn't rely on sdl.KEYDOWN event; instead,
    # you should check whether key is down in `update()` method

    # of sdl.KEYDOWN:
    #   case event.key.keysym.sym
    #     of K_t:
    #       var moveMessage = new(ref PlayerMoveMessage)
    #       moveMessage.send("network")
    #     else:
    #       discard

    else:
      discard

  # fallback to default implementation
  procCall self.as(ref sdl.InputSystem).handle(event)


method update(self: ref InputSystem, dt: float) =
  procCall self.as(ref sdl.InputSystem).update(dt)

  # process long-pressing key by polling keyboard state
  let
    keyboard = getKeyboardState(nil)

  var
    forward = keyboard[SCANCODE_W].bool
    backward = keyboard[SCANCODE_S].bool
    left = keyboard[SCANCODE_A].bool
    right = keyboard[SCANCODE_D].bool

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

    (ref PlayerMoveMessage)(yaw: yaw).send("network")
