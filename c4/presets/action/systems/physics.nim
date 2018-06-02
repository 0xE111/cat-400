import tables
import logging
import strformat

import "../../../systems"
import "../../../config"
import "../../../systems/physics/ode" as physics_system
import "../../../wrappers/ode/ode"
import "../../../core/entities"
import "../messages"

  
type
  ActionPhysicsSystem* = object of PhysicsSystem

  ActionPhysics* = object of Physics
    health*: uint8
    prevPosition: tuple[x, y, z: dReal]


method init*(self: ref ActionPhysicsSystem) =
  procCall ((ref PhysicsSystem)self).init()
  self.world.worldSetGravity(0, -1, 0)


method initComponent*(self: ref ActionPhysicsSystem, component: ref ActionPhysics) =
  procCall ((ref PhysicsSystem)self).initComponent(component)

  component.prevPosition = (0.0, 0.0, 0.0)


method update*(self: ref ActionPhysics, dt: float, entity: Entity) =
  # send only updated position
  let position = self.body.bodyGetPosition()[]
  if (position[0] != self.prevPosition.x) or (position[1] != self.prevPosition.y) or (position[1] != self.prevPosition.z):
    self.prevPosition = (position[0], position[1], position[2])
    (ref PhysicsMessage)(entity: entity, x: position[0], y: position[1], z: position[2]).send(config.systems.network)
