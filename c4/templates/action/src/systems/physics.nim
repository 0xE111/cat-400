import tables

import c4/lib/ode/ode as odelib

import c4/systems
import c4/entities
import c4/messages
import c4/systems/physics/ode
import c4/utils/stringify

import ../messages as action_messages


type
  PhysicsSystem* = object of ode.PhysicsSystem
    impersonationsMap*: Table[ref Peer, Entity]  ## Mapping from remote Peer to an Entity it's controlling

  Physics* = object of ode.Physics
    # additionally store previous position & rotation;
    # position/rotation update messages are sent only when values really changes
    prevPosition: array[3, dReal]
    prevRotation: dQuaternion

    movementDurationElapsed: float  # TODO: required only for players' nodes


const
  G* = 0  # 9.81

  # when received any movement command, this defines how long the movement will continue;
  # even if there's no command from client, the entity will continue moving during this period (in seconds)
  movementDuration = 0.1


# ---- Component ----

method init*(self: ref PhysicsSystem, physics: ref Physics) =
  procCall self.as(ref ode.PhysicsSystem).init(physics)

  physics.prevPosition = physics.body.bodyGetPosition()[]
  physics.prevRotation = physics.body.bodyGetQuaternion()[]

  physics.movementDurationElapsed = 0

proc startMovement*(self: ref Physics) =
  self.movementDurationElapsed = movementDuration


# ---- System ----
strMethod(PhysicsSystem, fields=false)

method init*(self: ref PhysicsSystem) =
  ## Sets real world gravity (G)
  procCall self.as(ref ode.PhysicsSystem).init()
  self.world.worldSetGravity(0, -G, 0)

method update*(self: ref Physics, dt: float, entity: Entity) =
  ## This method compares previous position and rotation of entity, and (if there are any changes) sends ``MoveMessage`` or ``RotateMessage``.
  let position = self.body.bodyGetPosition()[]
  for dimension in 0..2:
    if position[dimension] != self.prevPosition[dimension]:
      self.prevPosition = position
      (ref SetPositionMessage)(
        entity: entity,
        x: position[0],
        y: position[1],
        z: position[2],
      ).send("network")
      break

  let rotation = self.body.bodyGetQuaternion()[]
  for dimension in 0..3:
    if rotation[dimension] != self.prevRotation[dimension]:
      self.prevRotation = rotation
      (ref SetRotationMessage)(
        entity: entity,
        quaternion: rotation,
      ).send("network")
      break

  if self.movementDurationElapsed > 0:
    self.movementDurationElapsed -= dt
    if self.movementDurationElapsed <= 0:
      # it's time to stop movement
      self.body.bodySetLinearVel(0, 0, 0)
