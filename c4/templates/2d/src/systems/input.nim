import sdl2/sdl as sdllib

import c4/threads
import c4/systems/input/sdl

import ../messages


type InputSystem* = object of SdlInputSystem


# redefine input system methods below

method handle*(self: ref InputSystem, event: Event) =
  case event.kind
  of KEYDOWN:
    case event.key.keysym.sym
      of K_LEFT:
        (ref MoveMessage)(direction: left).send("network")
      of K_RIGHT:
        (ref MoveMessage)(direction: right).send("network")
      else:
        discard
  else:
    discard
