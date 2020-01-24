{.used.}
import sequtils
import tables
import math

import c4/threads
import c4/entities
import c4/systems/physics/simple
import c4/systems/network/enet

import ../systems/[network, physics]
import ../messages


method processRemote*(self: ref ServerNetworkSystem, message: ref MoveMessage) =
  message.entity = 0  # dismiss entity when message is non-local
  message.send("physics")


method process*(self: ref PhysicsSystem, message: ref MoveMessage) =
  if not message.entity.isInitialized:
    message.entity = self.player

  let physics = message.entity[ref Physics]

  physics.speed = (
    x: cos(message.direction) * movementSpeed,
    y: sin(message.direction) * movementSpeed,
  )
  physics.movementRemains = movementQuant
