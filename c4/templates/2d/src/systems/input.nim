import sdl2/sdl as sdllib

import c4/threads
import c4/systems/input/sdl

import ../messages


type InputSystem* = object of SdlInputSystem


# redefine input system methods below

method handle*(self: ref InputSystem, keyboard: ptr array[NUM_SCANCODES.int, uint8]) =
  let
    leftPressed = keyboard[SCANCODE_LEFT].bool
    rightPressed = keyboard[SCANCODE_RIGHT].bool

  if leftPressed and not rightPressed:
    (ref MoveMessage)(direction: left).send("network")
  elif rightPressed and not leftPressed:
    (ref MoveMessage)(direction: right).send("network")
