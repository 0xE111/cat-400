import sdl2

import c4/systems/input/sdl
import c4/systems/network/net
import c4/logging
import c4/messages
import c4/threads

import ../threads as thread_names


type
  InputSystem* = object of sdl.InputSystem
    connectionMessageSent: bool = false

  InputMessage* = object of NetworkMessage
    keys*: string


InputMessage.register()


method handleKeyboardState*(
  self: ref InputSystem,
  keyboard: ptr array[0 .. SDL_NUM_SCANCODES.int, uint8],
) =

  if keyboard[SDL_SCANCODE_C.int] > 0 and not self.connectionMessageSent:
    info "keyboard input - connection request"
    (ref ConnectMessage)(host: "127.0.0.1", port: 6543).send(networkThread)
    self.connectionMessageSent = true

  var keys = ""
  if keyboard[SDL_SCANCODE_W.int] > 0: keys.add "W"
  if keyboard[SDL_SCANCODE_S.int] > 0: keys.add "S"
  if keyboard[SDL_SCANCODE_A.int] > 0: keys.add "A"
  if keyboard[SDL_SCANCODE_D.int] > 0: keys.add "D"

  if keys.len > 0:
    info "keyboard input", keys
    (ref InputMessage)(keys: keys).send(networkThread)
