import tables

import c4/core
import c4/systems

import src/systems/physics
import src/systems/input
import src/systems/video
import src/systems/network

import src/scenarios


when isMainModule:
  core.run(
    serverSystems={
      "network": ServerNetworkSystem.new().as(ref System),
      "physics": PhysicsSystem.new().as(ref System),
    }.toOrderedTable(),
    clientSystems={
      "network": ClientNetworkSystem.new().as(ref System),
      "input": InputSystem.new().as(ref System),
      "video": VideoSystem.new().as(ref System),
    }.toOrderedTable(),
  )
