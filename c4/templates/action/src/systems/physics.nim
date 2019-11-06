import tables

import c4/lib/ode/ode as odelib

import c4/systems
import c4/entities
import c4/messages as c4messages
import c4/systems/physics/ode
import c4/utils/stringify

import ../messages


type
  PhysicsSystem* = object of ode.PhysicsSystem
    impersonationsMap*: Table[ref Peer, Entity] ## Mapping from remote Peer to an Entity it's controlling

    boxes*: seq[Entity]
    plane*: Entity

  Physics* = object of ode.Physics
    # additionally store previous position & rotation;
    # position/rotation update messages are sent only when values really changes
    prevPosition: array[3, dReal]
    prevRotation: dQuaternion

    movementDurationElapsed: float # TODO: required only for players' nodes

  BoxPhysics* = object of Physics
  PlanePhysics* = object of Physics


const
  G* = 0 # 9.81

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


method init*(self: ref PhysicsSystem, physics: ref BoxPhysics) =
  procCall self.init(physics.as(ref Physics))

  let geometry = createBox(self.space, 1, 1, 1)
  geometry.geomSetBody(physics.body)

  let mass = cast[ptr dMass](alloc(sizeof(dMass)))
  # TODO: var mass = ode.dMass()
  mass.massSetBoxTotal(1.0, 1.0, 1.0, 1.0)
  physics.body.bodySetMass(mass)

  # TODO: send geometry (AABB) to graphics system - AddGeometryMessage

################################################
method attach*(self: ref Physics) =
  discard
method detach*(self: ref Physics) =
  discard
################################################

# ---- System ----
strMethod(PhysicsSystem, fields = false)

method init*(self: ref PhysicsSystem) =
  procCall self.as(ref ode.PhysicsSystem).init()
  self.world.worldSetGravity(0, 0, 0)

method update*(self: ref PhysicsSystem, dt: float) =
  procCall self.as(ref ode.PhysicsSystem).update(dt)

  for entity, physics in getComponents(ref Physics).pairs:
    ## This method compares previous position and rotation of entity, and (if there are any changes) sends ``MoveMessage`` or ``RotateMessage``.
    let position = physics.body.bodyGetPosition()[]
    for dimension in 0..2:
      if position[dimension] != physics.prevPosition[dimension]:
        physics.prevPosition = position
        (ref SetPositionMessage)(
          entity: entity,
          x: position[0],
          y: position[1],
          z: position[2],
        ).send("network")
        break

    let rotation = physics.body.bodyGetQuaternion()[]
    for dimension in 0..3:
      if rotation[dimension] != physics.prevRotation[dimension]:
        physics.prevRotation = rotation
        (ref SetRotationMessage)(
          entity: entity,
          quaternion: rotation,
        ).send("network")
        break

    if physics.movementDurationElapsed > 0:
      physics.movementDurationElapsed -= dt
      if physics.movementDurationElapsed <= 0:
        # it's time to stop movement
        physics.body.bodySetLinearVel(0, 0, 0)
