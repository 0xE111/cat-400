import c4/threads
import c4/core

import src/systems/network
import src/systems/physics
import src/systems/input
import src/systems/video

import src/scenarios/init


when isMainModule:
  app do:
    spawn("network"):
      var network = ServerNetworkSystem()
      network.run()

    spawn("physics"):
      var physics = PhysicsSystem()
      physics.run()

    joinAll()

  do:
    spawn("network"):
      var network = ClientNetworkSystem()
      network.run()

    spawn("input"):
      var input = InputSystem()
      input.run()

    spawn("video"):
      var video = VideoSystem()
      video.run()

    joinAll()
