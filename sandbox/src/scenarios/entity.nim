import logging
import strformat

import c4/entities
import c4/systems/video/ogre

import ../systems/video


method process*(self: ref SandboxVideoSystem, message: ref CreateEntityMessage) =
  # sent by action network system when player connected and got new entity
  logging.debug &"Creating video component for entity {message.entity}"
  let video = new(BoxVideo)
  self.init(video)
  message.entity[ref Video] = video
