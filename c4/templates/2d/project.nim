import logging
import net
import strformat

import c4/threads
import c4/core
import c4/systems/network/enet
import c4/systems/physics/simple
import c4/systems/input/sdl
import c4/systems/video/sdl as sdlvideo

import src/systems/[network, physics, input, video]
import src/scenarios/[connection, movement, start]


when isMainModule:
  app do:
    spawn("network"):
      logging.addHandler(logging.newConsoleLogger(levelThreshold=getCmdLogLevel(), fmtStr="[$datetime] server $levelname: "))
      let network = new(ServerNetworkSystem)
      if not waitAvailable("physics"):
         raise newException(LibraryError, &"Physics system unavailable")
      network.init(port=Port(9000))
      network.run()
      network.dispose()

    spawn("physics"):
      logging.addHandler(logging.newConsoleLogger(levelThreshold=getCmdLogLevel(), fmtStr="[$datetime] physics $levelname: "))
      let physics = new(PhysicsSystem)
      physics.init()
      physics.run()
      physics.dispose()

    joinAll()

  do:
    spawn("network"):
      logging.addHandler(logging.newConsoleLogger(levelThreshold=getCmdLogLevel(), fmtStr="[$datetime] client $levelname: "))
      let network = new(ClientNetworkSystem)
      network.init()
      if not waitAvailable("input") or not waitAvailable("video"):
        raise newException(LibraryError, &"Input or Video system unavailable")
      network.connect(host="localhost", port=Port(9000))
      network.run()
      network.dispose()

    spawn("video"):
      logging.addHandler(logging.newConsoleLogger(levelThreshold=getCmdLogLevel(), fmtStr="[$datetime] video $levelname: "))
      let video = new(VideoSystem)
      video.init(windowX=300, windowY=300, windowWidth=640, windowHeight=640)
      video.run()
      video.dispose()

    spawn("input"):
      logging.addHandler(logging.newConsoleLogger(levelThreshold=getCmdLogLevel(), fmtStr="[$datetime] input $levelname: "))
      discard waitAvailable("video")
      let input = new(InputSystem)
      input.init()
      input.run()
      input.dispose()

    joinAll()
