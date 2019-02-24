import logging
import strformat

import ../../../config
import ../../../core/entities
import ../../../systems
import ../../../systems/network/enet
import ../../../systems/video/horde3d

import ../messages
import ../systems/network
import ../systems/video

import ../../../wrappers/horde3d/horde3d as horde3d_wrapper



method process*(self: ref ActionClientNetworkSystem, message: ref ImpersonationMessage) =
  ## When server tells client to occupy some entity, send this message to video system
  procCall self.as(ref ClientNetworkSystem).process(message)
  message.send(config.systems.video)


method process*(self: ref ActionVideoSystem, message: ref ImpersonationMessage) =
  ## Store player's entity in `playerNode`; attach camera to impersonated entity
  self.playerNode = message.entity[ref Video].node

  if not self.camera.setNodeParent(self.playerNode):
    const msg = "Could not attach camera to player node"
    logging.error msg
    raise newException(LibraryError, msg)

  logging.debug &"Camera attached to player node: {self.playerNode}"
