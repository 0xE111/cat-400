import logging
import net
import strformat

import c4/threads
import c4/core
import c4/systems/network/enet
import c4/systems/physics/simple
import c4/systems/input/sdl
import c4/systems/video/sdl as sdlvideo

import src/systems/network
import src/systems/physics
import src/systems/input
import src/systems/video

import src/scenarios/init


when isMainModule:
  app do:
    spawn("network"):
      logging.addHandler(logging.newConsoleLogger(levelThreshold=getCmdLogLevel(), fmtStr="[$datetime] server $levelname: "))
      var network = ServerNetworkSystem()
      network.init(port=Port(9000))
      network.run()
      network.dispose()

    spawn("physics"):
      logging.addHandler(logging.newConsoleLogger(levelThreshold=getCmdLogLevel(), fmtStr="[$datetime] physics $levelname: "))
      var physics = PhysicsSystem()
      physics.init()
      physics.run()
      physics.dispose()

    joinAll()

  do:
    spawn("network"):
      logging.addHandler(logging.newConsoleLogger(levelThreshold=getCmdLogLevel(), fmtStr="[$datetime] client $levelname: "))
      var network = ClientNetworkSystem()
      network.init()
      if not waitAvailable("input") or not waitAvailable("video"):
        raise newException(LibraryError, &"Input or Video system unavailable")
      network.connect(host="localhost", port=Port(9000))
      network.run()
      network.dispose()

    spawn("input"):
      logging.addHandler(logging.newConsoleLogger(levelThreshold=getCmdLogLevel(), fmtStr="[$datetime] input $levelname: "))
      var input = InputSystem()
      input.init()
      input.run()
      input.dispose()

    spawn("video"):
      logging.addHandler(logging.newConsoleLogger(levelThreshold=getCmdLogLevel(), fmtStr="[$datetime] video $levelname: "))
      var video = VideoSystem()
      video.init()
      video.run()
      video.dispose()

    joinAll()
