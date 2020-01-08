{.used.}
import sequtils
import tables

import c4/threads
import c4/entities
import c4/systems/physics/simple
import c4/systems/network/enet

import ../systems/[network, physics]
import ../messages


method processRemote*(self: ref ServerNetworkSystem, message: ref MoveMessage) =
  message.send("physics")


method process*(self: ref PhysicsSystem, message: ref MoveMessage) =
  let isRemote = not message.peer.isNil

  for entity in toSeq(getComponents(ref Control).pairs).filterIt(
    (if isRemote: it[1] of ref PlayerControl else: it[1] of ref AIControl)
  ).mapIt(it[0]):
    let physics = entity[ref Physics]

    physics.speed = (
      x: (if message.direction == left: -1 else: 1) * paddleMovementSpeed,
      y: 0.0,
    )
    physics.movementRemains = movementQuant
