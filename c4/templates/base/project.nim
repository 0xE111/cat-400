import tables

import c4/namedthreads

import src/systems/network
import src/systems/physics
import src/systems/input
import src/systems/video

import src/scenarios/init


when isMainModule:
  spawn("network") do:
    var network = ServerNetworkSystem()
    network.run()

  spawn("input") do:
    var input = InputSystem()
    input.run()

  spawn("physics") do:
    var physics = PhysicsSystem()
    physics.run()

  spawn("video") do:
    var video = VideoSystem()
    video.run()

  joinAll()
