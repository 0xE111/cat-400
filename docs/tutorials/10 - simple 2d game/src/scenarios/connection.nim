import c4/entities
import c4/threads
import c4/systems/network/net
import c4/systems/physics/simple

import ../systems/network
import ../systems/physics
import ../messages
import ../threads


method receive*(self: ref network.ServerNetworkSystem, message: ref HelloMessage) =
  message.send(physicsThread)

method process*(self: ref physics.PhysicsSystem, message: ref HelloMessage) =
  info "physics received hello message"

  # send entities messages to client
  for entity in iterEntities():
    let physics = entity[ref Physics]

    (ref EntityCreateMessage)(
      connection: message.connection,
      entity: entity,
      width: physics.width,
      height: physics.height,
    ).send(networkThread)

    (ref EntityMoveMessage)(
      connection: message.connection,
      entity: entity,
      x: physics.position.x,
      y: physics.position.y,
    ).send(networkThread)
