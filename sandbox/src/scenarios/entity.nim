import logging
import strformat

import c4/entities
import c4/systems/video/ogre

import ../systems/video


method process*(self: ref SandboxVideoSystem, message: ref CreateEntityMessage) =
  logging.debug &"Creating video component for {message.entity}"
  let video = SandboxVideo.new()
  self.init(video)
  message.entity[ref Video] = video
