import std/random

import c4/entities
import c4/threads
import c4/systems/network/net
import c4/systems/physics/simple

import ../systems/network
import ../systems/physics
import ../systems/video
import ../messages
import ../threads

var rand = initRand()


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
  try:
    message.entity = self.entitiesMap[message.entity]  # convert server's entity to client's one
  except KeyError:
    return
  message.send(videoThread)  # forward message to video thread

method process*(self: ref VideoSystem, message: ref EntityCreateMessage) =
  # create video component for new entity
  message.entity[ref Video] = (ref Video)(x: 0, y: 0, width: message.width, height: message.height)

method process*(self: ref VideoSystem, message: ref EntityMoveMessage) =
  # update video component
  let video = message.entity[ref Video]
  video.x = message.x
  video.y = message.y

method receive*(self: ref network.ServerNetworkSystem, message: ref MoveMessage) =
  message.send(physicsThread)

method process*(self: ref physics.PhysicsSystem, message: ref MoveMessage) =
  self.player[ref Physics].velocity = (x: 0, y: self.movementSpeed * (if message.up: -1 else: 1))

  let ballPhysics = self.ball[ref Physics]
  if ballPhysics.velocity == (x: 0.0, y: 0.0):
    ballPhysics.velocity = (x: rand.rand(self.movementSpeed), y: rand.rand(self.movementSpeed))
