import c4.config
import c4.core

import c4.presets.shooter.messages
import c4.presets.shooter.systems.input
import c4.presets.shooter.systems.video
import c4.presets.shooter.systems.physics
import c4.presets.shooter.systems.network

import states.server


config.title = "Sample game"
config.version = "0.1"
config.systems.input = new(ShooterInputSystem)
config.systems.video = new(ShooterVideoSystem)
config.systems.network = new(ShooterNetworkSystem)
config.settings.video.window.fullscreen = false


when isMainModule:
  core.run()
