import c4/core
import c4/namedthreads

import src/systems/physics
import src/systems/input
import src/systems/video
import src/systems/network

import src/scenarios/init
import src/scenarios/connection
import src/scenarios/entity
import src/scenarios/impersonation
import src/scenarios/player_actions
import src/scenarios/position


when isMainModule:
  app do:  # server systems
    spawn("network"):
      var system = ServerNetworkSystem()
      system.run()

    spawn("physics"):
      var system = PhysicsSystem()
      system.run()

  do:  # client systems
    spawn("network"):
      var system = ClientNetworkSystem()
      system.run()

    spawn("input"):
      var system = InputSystem()
      system.run()

    spawn("video"):
      var system = VideoSystem()
      system.run()
