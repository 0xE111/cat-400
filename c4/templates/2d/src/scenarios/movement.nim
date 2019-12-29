{.used.}
import c4/threads
import c4/entities
import c4/systems/physics/simple

import ../systems/[network, physics]
import ../messages


method processRemote*(self: ref ServerNetworkSystem, message: ref MoveMessage) =
  message.send("physics")


method process*(self: ref PhysicsSystem, message: ref MoveMessage) =
  let
    paddle = self.paddles[0]
    physics = paddle[ref Physics]

  if message.direction == left:
    physics.speed = (x: -0.02, y: 0.0)
  else:
    physics.speed = (x: 0.02, y: 0.0)
