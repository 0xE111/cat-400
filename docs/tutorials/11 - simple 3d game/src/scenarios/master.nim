import c4/entities
import c4/threads
import c4/logging
import c4/systems/network/net

import ../systems/network
import ../systems/video
import ../messages
import ../threads



method receive*(self: ref network.ClientNetworkSystem, message: ref EntityMoveMessage) =
  try:
    message.entity = self.entitiesMap[message.entity]  # convert server's entity to client's one
  except KeyError:
    warn "entity not found", entity=message.entity
    return  # move message was received before entity creation message -> do nothing
  debug "moving entity"
  message.send(videoThread)  # forward message to video thread

method process*(self: ref VideoSystem, message: ref EntityMoveMessage) =
  # update video component
  discard
  # let video = message.entity[ref Video]
  # video.x = message.x
  # video.y = message.y

# method receive*(self: ref network.ServerNetworkSystem, message: ref MoveMessage) =
#   message.send(physicsThread)

# method process*(self: ref physics.PhysicsSystem, message: ref MoveMessage) =
#   discard

#   # self.player[ref Physics].velocity = (x: 0, y: self.movementSpeed * (if message.up: -1 else: 1))

#   # let ballPhysics = self.ball[ref Physics]
#   # if ballPhysics.velocity == (x: 0.0, y: 0.0):
#   #   ballPhysics.velocity = (
#   #     x: max(200.0, rand.rand(self.movementSpeed)),
#   #     y: max(200.0, rand.rand(self.movementSpeed)),
#   #   )
