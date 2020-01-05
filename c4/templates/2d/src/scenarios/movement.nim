{.used.}
import random
import math

import c4/threads
import c4/entities
import c4/systems/physics/simple

import ../systems/[network, physics]
import ../messages


randomize()


method processRemote*(self: ref ServerNetworkSystem, message: ref MoveMessage) =
  message.send("physics")


method process*(self: ref PhysicsSystem, message: ref MoveMessage) =
  let
    paddle = self.paddles[1]
    physics = paddle[ref Physics]

  physics.speed = (
    x: (if message.direction == left: -1 else: 1) * paddleMovementSpeed,
    y: 0.0,
  )
  physics.movementRemains = movementQuant

  # start game when movement starts
  let ballPhysics = self.ball[ref Physics]
  if ballPhysics.speed == (0.0, 0.0):
    let angle = Pi / 180 * random(65..75).float  # rad
    ballPhysics.speed = (cos(angle) * ballSpeed, sin(angle) * ballSpeed)
