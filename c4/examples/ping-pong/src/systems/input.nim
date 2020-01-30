import sdl2/sdl as sdllib

import c4/types
import c4/threads
import c4/systems/input/sdl

import ../messages


type InputSystem* = object of SdlInputSystem


method handle*(self: ref InputSystem, event: Event) =
  ## Handling of basic event. These are pretty reasonable defaults.
  procCall self.as(ref SdlInputSystem).handle(event)

  if event.kind == KEYDOWN and event.key.keysym.sym == K_SPACE:
    new(StartGameMessage).send("network")


method handle*(self: ref InputSystem, keyboard: ptr array[NUM_SCANCODES.int, uint8]) =
  let
    leftPressed = keyboard[SCANCODE_LEFT].bool
    rightPressed = keyboard[SCANCODE_RIGHT].bool

  if leftPressed and not rightPressed:
    (ref MoveMessage)(direction: left).send("network")
  elif rightPressed and not leftPressed:
    (ref MoveMessage)(direction: right).send("network")
