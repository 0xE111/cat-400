import c4.config
import c4.core

import c4.presets.action.messages
import c4.presets.action.systems.input
import c4.presets.action.systems.video
import c4.presets.action.systems.physics
import c4.presets.action.systems.network

import states.server


config.title = "Sample game"
config.version = "0.1"
config.systems.physics = new(ActionPhysicsSystem)
config.systems.input = new(ActionInputSystem)
config.systems.video = new(ActionVideoSystem)
config.systems.network = new(ActionNetworkSystem)
config.settings.video.window.fullscreen = false


when isMainModule:
  core.run()
