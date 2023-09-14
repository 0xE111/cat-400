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

    movementSpeed*: float = 500.0


method process*(self: ref PhysicsSystem, message: ref PhysicsInitMessage) =
  self.player = newEntity()
  self.player[ref Physics] = (ref Physics)(width: 3, height: 100, position: (x: 20, y: 300))

  self.computer = newEntity()
  self.computer[ref Physics] = (ref Physics)(width: 3, height: 100, position: (x: 780, y: 300))

  # we make them fit precisely but not collide
  self.borders = [newEntity(), newEntity(), newEntity(), newEntity()]
  self.borders[0][ref Physics] = (ref Physics)(width: 1, height: 600-2, position: (x: 0.0, y: 300.0))  # left
  self.borders[1][ref Physics] = (ref Physics)(width: 1, height: 600-2, position: (x: 800.0, y: 300.0))  # right
  self.borders[2][ref Physics] = (ref Physics)(width: 800-2, height: 1, position: (x: 400.0, y: 0.0))  # up
  self.borders[3][ref Physics] = (ref Physics)(width: 800-2, height: 1, position: (x: 400.0, y: 600.0))  # down

  self.ball = newEntity()
  self.ball[ref Physics] = (ref Physics)(width: 6, height: 6, position: (x: 400.0, y: 300.0))

  debug "physics initialization finished"

proc reset*(self: ref PhysicsSystem) =
  let ballPhysics = self.ball[ref Physics]

  ballPhysics.position = (x: 400.0, y: 300.0)
  ballPhysics.velocity = (x: 0.0, y: 0.0)


method update*(self: ref PhysicsSystem, dt: float) {.gcsafe.} =
  let
    computerPhysics = self.computer[ref Physics]
    ballPhysics = self.ball[ref Physics]
  if computerPhysics.position.y > ballPhysics.position.y + 5:
    computerPhysics.velocity = (x: 0, y: -self.movementSpeed)
  elif computerPhysics.position.y < ballPhysics.position.y - 5:
    computerPhysics.velocity = (x: 0, y: self.movementSpeed)

  # move stuff
  procCall self.as(ref simple.PhysicsSystem).update(dt)

  for entity, physics in getComponents(ref Physics):
    if physics.position != physics.previousPosition:
      (ref EntityMoveMessage)(entity: entity, x: physics.position.x, y: physics.position.y).send(networkThread)

  # stop moving anything but the ball at the end of update cycle
  for entity, physics in getComponents(ref Physics):
    if entity != self.ball:
      physics.velocity = (x: 0.0, y: 0.0)

  if ballPhysics.position.x < self.player[ref Physics].position.x - 3:
    info "computer wins"
    self.reset()

  elif ballPhysics.position.x > computerPhysics.position.x + 3:
    info "player wins"
    self.reset()
