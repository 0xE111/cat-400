import c4/entities
import c4/threads
import c4/systems/network/net
import c4/systems/physics/simple

import ../systems/network
import ../systems/physics
import ../systems/video
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

method receive*(self: ref network.ClientNetworkSystem, message: ref EntityCreateMessage) =
  debug "creating entity"
  let entity = newEntity()
  self.entitiesMap[message.entity] = entity  # remember mapping from server's entity to client's one
  message.send(videoThread)  # forward message to video thread

method receive*(self: ref network.ClientNetworkSystem, message: ref EntityMoveMessage) =
  debug "moving entity"
  message.entity = self.entitiesMap[message.entity]  # convert server's entity to client's one
  message.send(videoThread)  # forward message to video thread

method process*(self: ref VideoSystem, message: ref EntityCreateMessage) =
  # create video component for new entity
  message.entity[ref Video] = (ref Video)(x: 0, y: 0, width: message.width, height: message.height)

method process*(self: ref VideoSystem, message: ref EntityMoveMessage) =
  # update video component
  let video = message.entity[ref Video]
  video.x = message.x
  video.y = message.y

method receive*(self: ref network.ServerNetworkSystem, message: ref MoveUpMessage) =
  message.send(physicsThread)

method receive*(self: ref network.ServerNetworkSystem, message: ref MoveDownMessage) =
  message.send(physicsThread)

method process*(self: ref physics.PhysicsSystem, message: ref MoveUpMessage) =
  self.player[ref Physics].velocity = (x: 0, y: -self.movementSpeed)

method process*(self: ref physics.PhysicsSystem, message: ref MoveDownMessage) =
  self.player[ref Physics].velocity = (x: 0, y: self.movementSpeed)
