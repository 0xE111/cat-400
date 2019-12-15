import sdl2/sdl as sdllib
import math
import net

import c4/threads
import c4/systems/input/sdl
import c4/systems/network/enet

import ../messages


type
  InputSystem* = object of sdl.InputSystem


proc handle*(self: InputSystem, event: Event) =
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
      ).send("network")

    of KEYDOWN:
      case event.key.keysym.sym
        of K_c:
          # When player presses "C" key, we want to establish connection to remote server. We create new ``ConnectMessage`` (which is already predefined in Enet networking system), set server address and send this message to network system. Default Enet networking system knows that it should connect to the server when receiving this kind of message.
          (ref ConnectMessage)(host: "localhost", port: Port(11477)).send("network")

        of K_q:
          # When player presses "Q" key, we want to disconnect from server. We create new ``DisconnectMessage`` (which is already predefined in Enet networking system), and sent this message to network system. Default Enet networking system knows that it should disconnect from the server when receiving this kind of message.
          new(DisconnectMessage).send("network")

        of K_r:
          # When player presses "R" key, we want server to reset the scene. We defined custom ``ResetSceneMessage`` and send it over the network.
          new(ResetSceneMessage).send("network")

        else:
          discard

    else:
      discard

  # fallback to default implementation
  sdl.InputSystem(self).handle(event)


proc update(self: InputSystem, dt: float) =
  # when some key is held down, there's usually a delay between first sdl.KEYDOWN event
  # and subsequent ones; so if you want to send some messages constantly when key is pressed
  # (for example, `PlayerMoveMessage`), you shouldn't rely on sdl.KEYDOWN event; instead,
  # you should check whether key is down in `update()` method

  sdl.InputSystem(self).update(dt)

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
