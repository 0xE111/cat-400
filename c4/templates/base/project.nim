import tables

import c4/namedthreads
import c4/core

import src/systems/network
import src/systems/physics
import src/systems/input
import src/systems/video

import src/scenarios/init


when isMainModule:
  app do:
    spawn("network") do:
      var network = ServerNetworkSystem()
      network.run()

    spawn("physics") do:
      var physics = PhysicsSystem()
      physics.run()

    joinAll()

  do:
    spawn("network") do:
      var network = ClientNetworkSystem()
      network.run()

    spawn("input") do:
      var input = InputSystem()
      input.run()

    spawn("video") do:
      var video = VideoSystem()
      video.run()

    joinAll()
