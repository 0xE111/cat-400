import sdl2

import c4/systems/input/sdl
import c4/logging
import c4/sugar
import c4/loop
import c4/threads as c4threads

import ../messages


type
  InputSystem* = object of sdl.InputSystem


method handleKeyboardState*(
  self: ref InputSystem,
  keyboard: ptr array[0 .. SDL_NUM_SCANCODES.int, uint8],
) =

  var keys = ""
  if keyboard[SDL_SCANCODE_W.int] > 0: keys.add "W"
  if keyboard[SDL_SCANCODE_S.int] > 0: keys.add "S"
  if keyboard[SDL_SCANCODE_A.int] > 0: keys.add "A"
  if keyboard[SDL_SCANCODE_D.int] > 0: keys.add "D"

  if keys.len > 0:
    info "keyboard input", keys

  if keyboard[SDL_SCANCODE_ESCAPE.int] > 0:
    new(StopMessage).send(c4threads.ThreadID(1))
    info "quit"
    raise newException(BreakLoopException, "")

method handleEvent*(self: ref InputSystem, event: Event) =
  procCall self.as(ref sdl.InputSystem).handleEvent(event)


  case event.kind
    of MOUSEMOTION:
      var x, y: cint
      discard getRelativeMouseState(x, y)
      if x != 0 or y != 0:
        info "mouse motion", x, y
    else:
      discard
