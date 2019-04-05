import logging
import strformat

import c4/core/entities
import c4/systems/video/bgfx

import ../systems/video


method process*(self: ref SandboxVideoSystem, message: ref CreateEntityMessage) =
  logging.debug &"Creating video component for {message.entity}"
  # message.entity[ref Video] = SandboxVideo.new()
