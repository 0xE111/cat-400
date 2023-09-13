import sequtils

import ../../systems
import ../../entities
import ../../messages
import ../../logging

type
  PhysicsSystem* = object of System

  Vector* = tuple[x: float, y: float]
  Physics* = object of RootObj
    position*: Vector
    previousPosition*: Vector
    width*, height*: float
    velocity*: Vector

  PhysicsInitMessage* = object of Message


register(PhysicsInitMessage)


proc topLeft*(self: Physics): Vector =
  (x: self.position.x - self.width/2, y: self.position.y + self.height/2)

proc bottomRight*(self: Physics): Vector =
  (x: self.position.x + self.width/2, y: self.position.y - self.height/2)

proc overlap*(self: Physics, other: Physics): bool =
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


method handleCollision*(self: ref PhysicsSystem, physics1: ref Physics, physics2: ref Physics) {.base, gcsafe.} =
  const eps = 0.02
  debug "collision happened", position1=physics1.position, position2=physics2.position

  # objects are collided using their horizontal edges
  if abs(physics1[].bottomRight.y - physics2[].topLeft.y) < eps or abs(physics1[].topLeft.y - physics2[].bottomRight.y) < eps:
    physics1.velocity = (physics1.velocity.x, -physics1.velocity.y)
    physics2.velocity = (physics2.velocity.x, -physics2.velocity.y)

  else:
    physics1.velocity = (-physics1.velocity.x, physics1.velocity.y)
    physics2.velocity = (-physics2.velocity.x, physics2.velocity.y)

  physics1.position = physics1.previousPosition
  physics2.position = physics2.previousPosition


method update*(self: ref Physics, dt: float) {.base, gcsafe.} =
  # calculate new position for every Physics instance
  self.previousPosition = self.position
  self.position = self.position + self.velocity * dt

method update*(self: ref PhysicsSystem, dt: float) {.gcsafe.} =
  let components = getComponents(ref Physics)

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

method process*(self: ref PhysicsSystem, message: ref PhysicsInitMessage) =
  discard


when isMainModule:
  import unittest
  import ../../threads

  suite "System tests":
    test "Running inside thread":
      spawnThread ThreadID(1):
        let system = new(PhysicsSystem)
        system.update(0.01)

      joinActiveThreads()
