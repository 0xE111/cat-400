import std/times

import c4/lib/ode/ode as libode
import c4/entities
import c4/systems/physics/ode
import c4/logging
import c4/sugar
import c4/threads

import ../messages
import ../threads

type
  PhysicsSystem* = object of ode.PhysicsSystem
    player*: Entity
    boxes*: array[8, Entity]

  Physics* = object of ode.Physics
    # additionally store previous position & rotation;
    # position/rotation update messages are sent only when values really changes
    prevPosition: array[3, dReal]
    prevRotation: dQuaternion


method process*(self: ref PhysicsSystem, message: ref PhysicsInitMessage) =
  procCall self.as(ref ode.PhysicsSystem).process(message)

  self.player = newEntity()
  self.player[ref Physics] = (ref Physics)(body: self.world.bodyCreate())
  self.player[ref Physics].body.bodySetPosition(0.0, 0.0, 0.0)

  for i in 0..<8:
    let entity = newEntity()
    entity[ref Physics] = (ref Physics)(body: self.world.bodyCreate())
    entity[ref Physics].body.bodySetPosition(i.float * 5.0, 0.0, -i.float * 5.0)


method update*(self: ref PhysicsSystem, dt: float) {.gcsafe.} =

  procCall self.as(ref ode.PhysicsSystem).update(dt)

  for entity, physics in getComponents(ref Physics):
    ## compare previous position and rotation of entity, and if there are any changes -
    ## send entity move/rotate message
    let position = physics.body.bodyGetPosition()[]
    for dimension in 0..2:
      if position[dimension] != physics.prevPosition[dimension]:
        physics.prevPosition = position
        (ref EntityMoveMessage)(
          entity: entity,
          x: position[0],
          y: position[1],
          z: position[2],
        ).send(networkThread)
        break

    let rotation = physics.body.bodyGetQuaternion()[]
    for dimension in 0..3:
      if rotation[dimension] != physics.prevRotation[dimension]:
        physics.prevRotation = rotation
        (ref EntityRotateMessage)(
          entity: entity,
          quaternion: rotation,
        ).send(networkThread)
        break

#     # if physics.movementDurationElapsed > 0:
#     #   physics.movementDurationElapsed -= dt
#     #   if physics.movementDurationElapsed <= 0:
#     #     # it's time to stop movement
#     #     physics.body.bodySetLinearVel(0, 0, 0)
