import c4/config
import c4/core

import src/systems/physics
import src/systems/input
import src/systems/video
import src/systems/network

import src/scenarios


config.title = "Sandbox"
config.version = "0.1"
config.systems.physics = new(SandboxPhysicsSystem)
config.systems.input = new(SandboxInputSystem)
config.systems.video = new(SandboxVideoSystem)
config.systems.network = new(SandboxNetworkSystem)
config.settings.video.window.fullscreen = false


when isMainModule:
  core.run()
