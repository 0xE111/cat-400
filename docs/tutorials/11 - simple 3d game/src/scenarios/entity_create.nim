import c4/entities
import c4/threads
import c4/logging
import c4/lib/ogre/ogre

import ../systems/network
import ../systems/video
import ../messages
import ../threads


method receive*(self: ref network.ClientNetworkSystem, message: ref EntityCreateMessage) =
  debug "creating entity"
  let entity = newEntity()
  self.entitiesMap[message.entity] = entity  # remember mapping from server's entity to client's one
  message.entity = entity
  message.send(videoThread)  # forward message to video thread


method process*(self: ref VideoSystem, message: ref EntityCreateMessage) =

  let node = self.sceneManager.getRootSceneNode().createChildSceneNode()
  let box = self.sceneManager.createEntity("box")
  node.attachObject(box)

  message.entity[ref Video] = (ref Video)(node: node)
  debug "created new video", entity=message.entity
