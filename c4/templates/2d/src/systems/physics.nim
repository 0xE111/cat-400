import c4/systems/physics/simple
import c4/entities

import ../messages


type PhysicsSystem* = object of SimplePhysicsSystem
  player*: Entity


proc init*(self: var PhysicsSystem) =
  # create a dummy player Entity
  self.player = newEntity()
  self.player[ref Physics] = (ref Physics)(width: 10, height: 10)
