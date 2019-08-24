import tables
import logging
import strformat
import math

import ../../../lib/ode/ode

import ../../../systems
import ../../../entities
import ../../../messages
import ../../../systems/physics/ode as physics_system
import ../../../systems/network/enet
import ../../../utils/stringify

import ../messages as action_messages


type
  ActionPhysicsSystem* = object of PhysicsSystem
    impersonationsMap*: Table[ref Peer, Entity]  ## Mapping from remote Peer to an Entity it's controlling

  ActionPhysics* = object of Physics
    # additionally store previous position & rotation;
    # position/rotation update messages are sent only when values really changes
    prevPosition: array[3, ode.dReal]
    prevRotation: ode.dQuaternion

    movementDurationElapsed: float


const
  G* = 0  #9.81

  # when received any movement command, this defines how long the movement will continue;
  # even if there's no command from client, the entity will continue moving during this period (in seconds)
  movementDuration = 0.1


# ---- Component ----
method attach*(self: ref ActionPhysics) =
  ## This method remembers component's inital position
  procCall self.as(ref Physics).attach()

  self.prevPosition = self.body.bodyGetPosition()[]
  self.prevRotation = self.body.bodyGetQuaternion()[]

  self.movementDurationElapsed = 0


proc startMovement*(self: ref ActionPhysics) =
  self.movementDurationElapsed = movementDuration


# ---- System ----
strMethod(ActionPhysicsSystem, fields=false)

method init*(self: ref ActionPhysicsSystem) =
  ## Sets real world gravity (G)
  procCall self.as(ref PhysicsSystem).init()
  self.world.worldSetGravity(0, -G, 0)

method update*(self: ref ActionPhysics, dt: float, entity: Entity) =
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
      ).send(systems.get("network"))
      break

  let rotation = self.body.bodyGetQuaternion()[]
  for dimension in 0..3:
    if rotation[dimension] != self.prevRotation[dimension]:
      self.prevRotation = rotation
      (ref SetRotationMessage)(
        entity: entity,
        quaternion: rotation,
      ).send(systems.get("network"))
      break

  if self.movementDurationElapsed > 0:
    self.movementDurationElapsed -= dt
    if self.movementDurationElapsed <= 0:
      # it's time to stop movement
      self.body.bodySetLinearVel(0, 0, 0)
