{.used.}
import math
import random

import c4/entities
import c4/threads
import c4/systems/physics/simple

import ../messages
import ../systems/network
import ../systems/physics


randomize()


method processRemote*(self: ref ServerNetworkSystem, message: ref StartGameMessage) =
  message.send("physics")


method process*(self: ref PhysicsSystem, message: ref StartGameMessage) =
  # start game when movement starts
  let ballPhysics = self.ball[ref Physics]
  if ballPhysics.speed == (0.0, 0.0):
    let angle = Pi / 180.0 * random(1..4).float * random(55..75).float  # rad
    ballPhysics.speed = (cos(angle) * ballSpeed, sin(angle) * ballSpeed)


proc resetBall*(self: ref PhysicsSystem) =
  self.ball[ref Physics].speed = (x: 0.0, y: 0.0)
  self.ball[ref Physics].position = (x: 0.5, y: 0.5)


method handleCollision*(self: ref PhysicsSystem, entity1: Entity, entity2: Entity) =
  procCall (ref SimplePhysicsSystem)(self).handleCollision(entity1, entity2)

  # check that one entity is a ball
  if self.ball notin [entity1, entity2]:
    return

  if self.gates[0] in [entity1, entity2]:
    # gates #2 win
    echo "---------- Player wins ----------"
    self.resetBall()

  elif self.gates[1] in [entity1, entity2]:
    # gates #1 win
    echo "---------- AI wins ----------"
    self.resetBall()
