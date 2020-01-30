import sdl2/sdl as sdllib
import math

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
  var vector = (x: 0.0, y: 0.0)

  if keyboard[SCANCODE_LEFT].bool:
    vector = (x: vector.x - 1.0, y: vector.y + 0.0)

  if keyboard[SCANCODE_RIGHT].bool:
    vector = (x: vector. x + 1.0, y: vector.y + 0.0)

  if keyboard[SCANCODE_UP].bool:
    vector = (x: vector.x + 0.0, y: vector.y + 1.0)

  if keyboard[SCANCODE_DOWN].bool:
    vector = (x: vector.x + 0.0, y: vector.y - 1.0)

  if vector == (x: 0.0, y: 0.0):
    return

  let angle = arctan2(vector.y, vector.x)
  (ref MoveMessage)(direction: angle).send("network")
