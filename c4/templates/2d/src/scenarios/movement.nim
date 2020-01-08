{.used.}
import sequtils
import tables

import c4/threads
import c4/entities
import c4/systems/physics/simple

import ../systems/[network, physics]
import ../messages


method processRemote*(self: ref ServerNetworkSystem, message: ref MoveMessage) =
  message.send("physics")


method process*(self: ref PhysicsSystem, message: ref MoveMessage) =
  for entity in toSeq(getComponents(ref Control).pairs).filterIt(it[1] of ref PlayerControl).mapIt(it[0]):
    let physics = entity[ref Physics]

    physics.speed = (
      x: (if message.direction == left: -1 else: 1) * paddleMovementSpeed,
      y: 0.0,
    )
    physics.movementRemains = movementQuant
