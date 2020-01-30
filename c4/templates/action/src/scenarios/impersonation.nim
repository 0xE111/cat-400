when defined(nimHasUsed):
  {.used.}

import logging
import strformat
import tables

import c4/types
import c4/entities
import c4/systems
import c4/systems/network/enet
import c4/systems/video/ogre
import c4/lib/ogre/ogre as ogrelib

import ../messages
import ../systems/network
import ../systems/video


method process*(self: ref network.ClientNetworkSystem, message: ref ImpersonationMessage) =
  ## When server tells client to occupy some entity, send this message to video system
  procCall self.as(ref enet.ClientNetworkSystem).process(message)
  message.send("video")


method process*(self: ref video.VideoSystem, message: ref ImpersonationMessage) =
  ## Store player's entity in `playerNode`; attach camera to impersonated entity
  self.playerNode = message.entity[ref Video].node

  self.playerNode.attachObject(self.camera)
  logging.debug &"Camera attached to player node"
