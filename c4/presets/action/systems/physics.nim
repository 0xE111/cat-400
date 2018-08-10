import tables
import logging
import strformat
import typetraits

import "../../../systems"
import "../../../config"
import "../../../core/entities"
import "../../../core/messages"
import "../../../systems/physics/ode" as physics_system
import "../../../systems/network/enet"
import "../../../wrappers/ode/ode"
import "../../../wrappers/ode/ode/helpers"
import "../../../utils/stringify"

import "../messages" as action_messages


type
  ActionPhysicsSystem* = object of PhysicsSystem
    peersEntities*: Table[ref Peer, Entity]  ## Table for converting remote Peer to Entity which he has control over

  ActionPhysics* = object of Physics
    ## Physics component which additionally stores its previous position. Position update messages are sent only when position really changes.
    prevPosition: tuple[x, y, z: dReal]


const
  G* = 9.81


method init*(self: ref ActionPhysicsSystem) =
  ## Sets real world gravity (G) 
  procCall self.as(ref PhysicsSystem).init()
  
  self.peersEntities = initTable[ref Peer, Entity]()
  self.world.worldSetGravity(0, -G, 0)

method initComponent*(self: ref ActionPhysicsSystem, component: ref ActionPhysics) =
  ## This method remembers component's inital position
  procCall self.as(ref PhysicsSystem).initComponent(component)

  let position = component.body.getPosition()
  component.prevPosition = (position.x, position.y, position.z)

method update*(self: ref ActionPhysics, dt: float, entity: Entity) =
  ## This method compares previous position and rotation of entity, and (if there are any changes) sends ``MoveMessage`` or ``RotateMessage``.
  let position = self.body.getPosition()
  if (position.x != self.prevPosition.x) or (position.y != self.prevPosition.y) or (position.z != self.prevPosition.z):
    self.prevPosition = (position.x, position.y, position.z)
    (ref SetPositionMessage)(
      entity: entity,
      x: position.x,
      y: position.y,
      z: position.z,
    ).send(config.systems.network)

  # TODO: implement rotation
    #   pitch: 0.0,  
    #   yaw: 0.0,
    # ).send(config.systems.network)
