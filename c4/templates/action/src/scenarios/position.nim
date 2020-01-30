when defined(nimHasUsed):
  {.used.}

import logging
import strformat

import c4/lib/ogre/ogre as ogrelib

import c4/types
import c4/entities
import c4/systems
import c4/systems/video/ogre
import c4/systems/network/enet

import ../systems/video
import ../systems/network
import ../messages


method process*(self: ref network.ClientNetworkSystem, message: ref SetPositionMessage) =
  procCall self.as(ref enet.ClientNetworkSystem).process(message)
  message.send("video")


method process(self: ref video.VideoSystem, message: ref SetPositionMessage) =
  if not message.entity.has(ref Video):
    logging.warn &"{$(self)} received {$(message)}, but has no Video component"
    # raise newException(LibraryError, "Shit im getting errors")
    # TODO: When client just connected to server, the server still may broadcast some messages
    # before syncing world state with client. When these messages reach client, it doesn't have
    # corresponding components yet, thus won't be able to process these messages and fail.
    return

  message.entity[ref Video].node.setPosition(message.x, message.y, message.z)


method process*(self: ref network.ClientNetworkSystem, message: ref SetRotationMessage) =
  ## Forward the message to video system
  procCall self.as(ref enet.ClientNetworkSystem).process(message)
  message.send("video")


method process*(self: ref video.VideoSystem, message: ref SetRotationMessage) =
  if not message.entity.has(ref Video):
    logging.warn &"{$(self)} received {$(message)}, but has no Video component"
    return

  message.entity[ref Video].node.setOrientation(
    message.quaternion[0],
    message.quaternion[1],
    message.quaternion[2],
    message.quaternion[3],
  )
