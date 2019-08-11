import logging
import strformat
import math
import tables

import ../../../lib/ogre/ogre

import ../../../core
import ../../../core/messages
import ../../../core/entities
import ../../../systems as systems_module
import ../../../systems/video/ogre as ogre_video
import ../../../systems/network/enet as enet_network
import ../systems/video
import ../systems/input
import ../systems/network
import ../messages as action_messages


method process*(self: ref ActionClientNetworkSystem, message: ref SetPositionMessage) =
  procCall self.as(ref ClientNetworkSystem).process(message)
  message.send(systems["video"])


method process(self: ref ActionVideoSystem, message: ref SetPositionMessage) =
  if not message.entity.has(ref Video):
    logging.warn &"{$(self)} received {$(message)}, but has no Video component"
    # raise newException(LibraryError, "Shit im getting errors")
    # TODO: When client just connected to server, the server still may broadcast some messages
    # before syncing world state with client. When these messages reach client, it doesn't have
    # corresponding components yet, thus won't be able to process these messages and fail.
    return

  message.entity[ref Video].node.setPosition(message.x, message.y, message.z)


method process*(self: ref ActionClientNetworkSystem, message: ref SetRotationMessage) =
  ## Forward the message to video system
  procCall self.as(ref ClientNetworkSystem).process(message)
  message.send(systems["video"])


method process*(self: ref ActionVideoSystem, message: ref SetRotationMessage) =
  if not message.entity.has(ref Video):
    logging.warn &"{$(self)} received {$(message)}, but has no Video component"
    return

  message.entity[ref Video].node.setOrientation(
    message.quaternion[0],
    message.quaternion[1],
    message.quaternion[2],
    message.quaternion[3],
  )
