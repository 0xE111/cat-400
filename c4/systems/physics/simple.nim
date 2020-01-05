import tables
import logging
import strformat
import os
when isMainModule:
  import unittest

import ../../entities
import ../../messages
import ../../loop
import ../../threads


type
  SimplePhysicsSystem* {.inheritable.} = object

  Vector* = tuple[x: float, y: float]

  SimplePhysics* {.inheritable.} = object
    position*: Vector
    previousPosition*: Vector
    width*, height*: float
    speed*: Vector  # defines direction & speed


proc topLeft*(self: SimplePhysics): Vector = (x: self.position.x - self.width/2, y: self.position.y + self.height/2)
proc bottomRight*(self: SimplePhysics): Vector = (x: self.position.x + self.width/2, y: self.position.y - self.height/2)

proc overlap*(self: SimplePhysics, other: SimplePhysics): bool =
  if self.topLeft.x > other.bottomRight.x or other.topLeft.x > self.bottomRight.x:
    return false

  if self.topLeft.y < other.bottomRight.y or other.topLeft.y < self.bottomRight.y:
    return false

  true


proc `+`*(v1: Vector, v2: Vector): Vector =
  result.x = v1.x + v2.x
  result.y = v1.y + v2.y

proc `*`*(v: Vector, mul: float): Vector =
  result.x = v.x * mul
  result.y = v.y * mul


method init*(self: ref SimplePhysicsSystem) {.base.} =
  discard

method handleCollision*(self: ref SimplePhysicsSystem, physics1: ref SimplePhysics, physics2: ref SimplePhysics) =
  physics1.position = physics1.previousPosition
  physics1.speed = (x: 0.0, y: 0.0)

  physics2.position = physics2.previousPosition
  physics2.speed = (x: 0.0, y: 0.0)

method getComponents*(self: ref SimplePhysicsSystem): Table[Entity, ref SimplePhysics] {.base.} =
  getComponents(ref SimplePhysics)

method update*(self: ref SimplePhysics, dt: float) {.base.} =
  # calculate new position for every Physics instance
  self.previousPosition = self.position
  self.position = self.position + self.speed * dt

method update*(self: ref SimplePhysicsSystem, dt: float) {.base.} =
  let components = self.getComponents()

  for entity, physics in components:
    physics.update(dt)

  let
    entities = toSeq(components.keys)
    length = entities.len

  for i in 0..<length-1:
    for j in i+1..length-1:
      let
        physics1 = components[entities[i]]
        physics2 = components[entities[j]]

      if overlap(physics1[], physics2[]):
        self.handleCollision(physics1, physics2)


method dispose*(self: ref SimplePhysicsSystem) {.base.} =
  discard

method process*(self: ref SimplePhysicsSystem, message: ref Message) {.base.} =
  logging.warn &"Don't know how to process {message}"

method run*(self: ref SimplePhysicsSystem) {.base.} =
  loop(frequency=30) do:
    self.update(dt)
    while true:
      let message = tryRecv()
      if message.isNil:
        break
      self.process(message)


when isMainModule:
  suite "System tests":
    test "Running inside thread":
      spawn("thread") do:
        let system = new(SimplePhysicsSystem)
        system.init()
        system.run()
        system.dispose()

      sleep 1000
