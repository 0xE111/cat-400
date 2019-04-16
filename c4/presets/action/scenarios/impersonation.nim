import logging
import strformat
import tables

import ../../../config
import ../../../core/entities
import ../../../systems as systems_module
import ../../../systems/network/enet
import ../../../systems/video/ogre as ogre_video
import ../../../lib/ogre/ogre

import ../messages
import ../systems/network
import ../systems/video



method process*(self: ref ActionClientNetworkSystem, message: ref ImpersonationMessage) =
  ## When server tells client to occupy some entity, send this message to video system
  procCall self.as(ref ClientNetworkSystem).process(message)
  message.send(systems["video"])


method process*(self: ref ActionVideoSystem, message: ref ImpersonationMessage) =
  ## Store player's entity in `playerNode`; attach camera to impersonated entity
  self.playerNode = message.entity[ref Video].node

  self.playerNode.attachObject(self.camera)
  logging.debug &"Camera attached to player node"
