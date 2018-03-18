from logging import debug
from utils.loop import runLoop, getFps
from utils.loading import load
from conf import Config
from systems.network import init, update

load "core/messages"


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
      messages.queue.flush()
      return true,
  )

  logging.debug("Server shutdown")
