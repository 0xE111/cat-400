import c4/entities
import c4/systems/physics/simple
import c4/logging
import c4/sugar
import c4/threads

import ../messages
import ../threads

type
  PhysicsSystem* = object of simple.PhysicsSystem
    borders*: array[4, Entity]
    player*: Entity
    computer*: Entity
    ball*: Entity

    movementSpeed*: float = 100.0


method process*(self: ref PhysicsSystem, message: ref PhysicsInitMessage) =
  self.player = newEntity()
  self.player[ref Physics] = (ref Physics)(width: 3, height: 100, position: (x: 20, y: 300))

  self.computer = newEntity()
  self.computer[ref Physics] = (ref Physics)(width: 3, height: 100, position: (x: 780, y: 300))

  self.borders = [newEntity(), newEntity(), newEntity(), newEntity()]
  self.borders[0][ref Physics] = (ref Physics)(width: 6, height: 600, position: (x: 0.0, y: 300.0))  # left
  self.borders[1][ref Physics] = (ref Physics)(width: 6, height: 600, position: (x: 800.0, y: 300.0))  # right
  self.borders[2][ref Physics] = (ref Physics)(width: 800, height: 6, position: (x: 400.0, y: 0.0))  # up
  self.borders[3][ref Physics] = (ref Physics)(width: 800, height: 3, position: (x: 400.0, y: 600.0))  # down

  self.ball = newEntity()
  self.ball[ref Physics] = (ref Physics)(width: 6, height: 6, position: (x: 400.0, y: 300.0))

  debug "physics initialization finished"

method update*(self: ref PhysicsSystem, dt: float) {.gcsafe.} =
  procCall self.as(ref simple.PhysicsSystem).update(dt)
  for entity, physics in getComponents(ref Physics):
    if physics.position != physics.previousPosition:
      (ref EntityMoveMessage)(entity: entity, x: physics.position.x, y: physics.position.y).send(networkThread)
