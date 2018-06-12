import tables
import logging
import strformat
import typetraits

import "../../../systems"
import "../../../config"
import "../../../core/messages"
import "../../../core/entities"
import "../../../systems/physics/ode" as physics_system
import "../../../systems/network/enet"
import "../../../wrappers/ode/ode"

  
type
  ActionPhysicsSystem* = object of PhysicsSystem

  ActionPhysics* = object of Physics
    prevPosition: tuple[x, y, z: dReal]

  MoveMessage* = object of EntityMessage
    x*, y*, z*: float

  RotateMessage* = object of EntityMessage
    yaw*, pitch*: float


messages.register(MoveMessage)
method `$`*(self: ref MoveMessage): string = &"{self[].type.name}: {self.x}, {self.y}, {self.z} (entity {self.entity})"

messages.register(RotateMessage)
method `$`*(self: ref RotateMessage): string = &"{self[].type.name}: {self.yaw}°:{self.pitch}° (entity {self.entity})"


const
  G* = 9.81


method init*(self: ref ActionPhysicsSystem) =
  ## Sets real world gravity (G) 
  procCall ((ref PhysicsSystem)self).init()
  
  self.world.worldSetGravity(0, -G, 0)

method initComponent*(self: ref ActionPhysicsSystem, component: ref ActionPhysics) =
  ## This method remembers component's inital position
  procCall ((ref PhysicsSystem)self).initComponent(component)

  component.prevPosition = (0.0, 0.0, 0.0)  # TODO: do not hardcode values, get position from initialized component

method update*(self: ref ActionPhysics, dt: float, entity: Entity) =
  ## This method compares previous position and rotation of emtity, and (if there are any changes) sends ``MoveMessage`` or ``RotateMessage``.
  let position = self.body.bodyGetPosition()[]
  if (position[0] != self.prevPosition.x) or (position[1] != self.prevPosition.y) or (position[1] != self.prevPosition.z):
    self.prevPosition = (position[0], position[1], position[2])
    (ref MoveMessage)(
      entity: entity,
      x: position[0],
      y: position[1],
      z: position[2],
    ).send(config.systems.network)

  # TODO: implement rotation
    #   pitch: 0.0,  
    #   yaw: 0.0,
    # ).send(config.systems.network)


method process*(self: ref ActionPhysicsSystem, message: ref ConnectMessage) =
  logging.debug &"Physics system received {message}"

method process*(self: ref ActionPhysicsSystem, message: ref DisconnectMessage) =
  logging.debug &"Physics system received {message}"
