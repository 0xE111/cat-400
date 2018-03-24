from logging import debug
from utils.loop import runLoop, getFps
from conf import Config
from systems.network import init, update
from systems.physics import init, update


proc run*(config: Config) =
  logging.debug("Starting server")
 
  var network = config.systems.network.instance
  network.init(port=config.systems.network.port)

  var physics = config.systems.physics.instance
  physics.init()

  runLoop(
    updatesPerSecond = 30,
    maxFrequencyCallback = proc(dt: float): bool =
      physics.update(dt)
      network.update(dt)
      return true,
  )

  logging.debug("Server shutdown")
