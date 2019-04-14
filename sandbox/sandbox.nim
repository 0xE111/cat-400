import tables

import c4/config
import c4/core
import c4/systems as systems_module

import src/systems/physics
import src/systems/input
import src/systems/video
import src/systems/network

import c4/presets/action/scenarios  # TODO: automatically import this somehow?
import src/scenarios as sandbox_scenarios

config.serverSystems.add("network", SandboxServerNetworkSystem.new())
config.serverSystems.add("physics", SandboxPhysicsSystem.new())

config.clientSystems.add("network", SandboxClientNetworkSystem.new())
config.clientSystems.add("input", SandboxInputSystem.new())
config.clientSystems.add("video", SandboxVideoSystem.new())

when isMainModule:
  core.run()
