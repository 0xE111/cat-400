from logging import debug
from utils.loop import runLoop, getFps
from conf import Config
from systems.network import init, update
from core.messages import flush


proc run*(config: Config) =
  logging.debug("Starting server")
 
  var network = config.systems.network.instance
  network.init(port=config.systems.network.port)

  runLoop(
    updatesPerSecond = 30,
    maxFrequencyCallback = proc(dt: float): bool =
      network.update(dt)
      return true,
    fixedFrequencyCallback = proc(dt: float): bool =
      messages.flush()
      return true,
  )

  logging.debug("Server shutdown")
