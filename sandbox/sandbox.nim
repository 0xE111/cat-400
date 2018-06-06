import c4.config
import c4.core

import c4.presets.action.systems.video
import c4.presets.action.systems.network

import src.systems.physics
import src.systems.input


config.title = "Sandbox"
config.version = "0.1"
config.systems.physics = new(SandboxPhysicsSystem)
config.systems.input = new(SandboxInputSystem)
config.systems.video = new(ActionVideoSystem)
config.systems.network = new(ActionNetworkSystem)
config.settings.video.window.fullscreen = false


when isMainModule:
  core.run()
