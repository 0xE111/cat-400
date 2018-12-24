import logging
import strformat

import ../../../config
import ../../../systems
import ../../../systems/network/enet

import ../messages
import ../systems/network
import ../systems/video

import ../../../wrappers/horde3d/horde3d


method process*(self: ref ActionNetworkSystem, message: ref ImpersonationMessage) =
  ## When server tells client to occupy some entity, send this message to video system
  assert mode == client

  procCall self.as(ref NetworkSystem).process(message)
  message.send(config.systems.video)


method process*(self: ref ActionVideoSystem, message: ref ImpersonationMessage) =
  ## Store player's entity in `playerNode`; attach camera to impersonated entity
  self.playerNode = message.entity

  if not self.camera.setNodeParent(self.playerNode):
    const msg = "Could not attach camera to player node"
    logging.error msg
    raise newException(LibraryError, msg)

  logging.debug &"Camera attached to player node: {self.playerNode}"
