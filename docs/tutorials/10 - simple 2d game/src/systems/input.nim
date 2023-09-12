import sdl2

import c4/logging
import c4/threads
import c4/systems/input/sdl

import ../messages
import ../threads


type
  InputSystem* = object of sdl.InputSystem


method handleKeyboardState*(
  self: ref InputSystem,
  keyboard: ptr array[0 .. SDL_NUM_SCANCODES.int, uint8],
) =

  var direction = 0
  if keyboard[SDL_SCANCODE_UP.int] > 0: direction += 1
  if keyboard[SDL_SCANCODE_DOWN.int] > 0: direction -= 1

  case direction:
    of 1:
      new(MoveUpMessage).send(networkThread)
    of -1:
      new(MoveDownMessage).send(networkThread)
    else:
      discard

  # if keys.len > 0:
  #   info "keyboard input", keys

  # if keyboard[SDL_SCANCODE_ESCAPE.int] > 0:
  #   new(StopMessage).send(c4threads.ThreadID(1))
  #   info "quit"
  #   raise newException(BreakLoopException, "")
