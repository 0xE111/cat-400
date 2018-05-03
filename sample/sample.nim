import c4.config
import c4.core

import systems.physics
import systems.input
import systems.video
import systems.network

import core.messages
import core.states.server


config.title = "Sample game"
config.version = "0.1"
config.systems.input = new(CustomInputSystem)
config.systems.video = new(CustomVideoSystem)
config.settings.video.window.fullscreen = false


when isMainModule:
  core.run()
