import logging
import random

import c4/sugar
import c4/entities
import c4/systems/physics/simple

import ../systems/physics


randomize()


method handleCollision*(self: ref PhysicsSystem, entity1: Entity, entity2: Entity) =
  if self.player in [entity1, entity2] and (entity1 in self.enemies or entity2 in self.enemies):
    logging.info "---- Enemies caught player! ----"
    self.player[ref Physics].position = (x: 0.5, y: 0.5)
    for enemy in self.enemies:
      enemy[ref Physics].position = (x: rand(100).float / 100.0, y: rand(100).float / 100.0)

  elif entity1 in self.enemies and entity2 in self.enemies:
    discard

  else:
    procCall self.as(ref SimplePhysicsSystem).handleCollision(entity1, entity2)
