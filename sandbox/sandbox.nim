import tables

import c4/core
import c4/systems

import src/systems/physics
import src/systems/input
import src/systems/video
import src/systems/network

import c4/presets/action/scenarios  # TODO: automatically import this somehow?
import src/scenarios as sandbox_scenarios 

when isMainModule:
  core.run(
    serverSystems={
      "network": SandboxServerNetworkSystem.new().as(ref System),
      "physics": SandboxPhysicsSystem.new().as(ref System),
    }.toOrderedTable(),
    clientSystems={
      "network": SandboxClientNetworkSystem.new().as(ref System),
      "input": SandboxInputSystem.new().as(ref System),
      "video": SandboxVideoSystem.new().as(ref System),
    }.toOrderedTable(),
  )
