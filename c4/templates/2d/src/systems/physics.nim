import tables
import strformat
import math
import sequtils

import c4/threads
import c4/systems/physics/simple
import c4/entities

import ../messages


const
  movementQuant* = 1/30  # synced with physics FPS
  movementSpeed* = 0.5
  numEnemies = 4

type
  PhysicsSystem* = object of SimplePhysicsSystem
    player*: Entity
    enemies*: seq[Entity]
    walls*: seq[Entity]

  Physics* = object of SimplePhysics
    movementRemains*: float

  Control* {.inheritable.} = object
  PlayerControl* = object of Control
  AIControl* = object of Control


method getComponents*(self: ref PhysicsSystem): Table[Entity, ref SimplePhysics] =
  cast[Table[Entity, ref SimplePhysics]](getComponents(ref Physics))

method init*(self: ref PhysicsSystem) =
  # player
  self.player = newEntity()
  self.player[ref Physics] = (ref Physics)(position: (x: 0.5, y: 0.9), width: 0.02, height: 0.02)
  self.player[ref Control] = new(PlayerControl)

  # enemies

  for i in 0..<numEnemies:
    let enemy = newEntity()
    enemy[ref Physics] = (ref Physics)(position: (x: (i+1)*1/(numEnemies+1), y: 0.1), width: 0.02, height: 0.02)
    enemy[ref Control] = new(AIControl)
    self.enemies.add(enemy)

  # walls
  let leftWall = newEntity()
  leftWall[ref Physics] = (ref Physics)(position: (x: 0.0, y: 0.5), width: 0.02, height: 1.0)
  self.walls.add(leftWall)

  let rightWall = newEntity()
  rightWall[ref Physics] = (ref Physics)(position: (x: 1.0, y: 0.5), width: 0.02, height: 1.0)
  self.walls.add(rightWall)

  let bottomWall = newEntity()
  bottomWall[ref Physics] = (ref Physics)(position: (x: 0.5, y: 0.0), width: 1.0, height: 0.02)
  self.walls.add(bottomWall)

  let upperWall = newEntity()
  upperWall[ref Physics] = (ref Physics)(position: (x: 0.5, y: 1.0), width: 1.0, height: 0.02)
  self.walls.add(upperWall)


proc dist(v1, v2: Vector): float =
  sqrt((v1.x - v2.x) ^ 2 + (v1.y - v2.y) ^ 2)


method update*(self: ref PhysicsSystem, dt: float) =
  procCall (ref SimplePhysicsSystem)(self).update(dt)

  for entity in concat(@[self.player], self.enemies):
    let physics = entity[ref Physics]
    if physics.movementRemains > 0:
      physics.movementRemains -= dt
      if physics.movementRemains < 0:
        physics.movementRemains = 0
        physics.speed = (x: 0.0, y: 0.0)

  for entity, physics in getComponents(ref Physics):
    if physics.position != physics.previousPosition:
      (ref SetPositionMessage)(
        entity: entity,
        x: physics.position.x,
        y: physics.position.y,
      ).send("network")

  # simple AI logic
  for entity in toSeq(getComponents(ref Control).pairs).filterIt(it[1] of ref AIControl).mapIt(it[0]):
    let
      entityPhysics = entity[ref Physics]
      playerPhysics = self.player[ref Physics]

    if playerPhysics.speed == (x: 0.0, y: 0.0):
      return

    let
      delta = 0.01
      xPlayerDelta = playerPhysics.position.x - entityPhysics.position.x
      yPlayerDelta = playerPhysics.position.y - entityPhysics.position.y

    if abs(xPlayerDelta) < delta and abs(yPlayerDelta) < delta:
      continue

    let angle = arctan2(yPlayerDelta, xPlayerDelta)
    (ref MoveMessage)(entity: entity, direction: angle).send()
