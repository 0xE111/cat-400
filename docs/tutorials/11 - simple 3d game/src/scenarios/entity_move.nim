import c4/entities
import c4/threads
import c4/logging
import c4/lib/ogre/ogre

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
  let video = message.entity[ref Video]
  video.node.setPosition(x=message.x, y=message.y, z=message.z)
