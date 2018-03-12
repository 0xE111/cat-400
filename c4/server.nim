from logging import debug
from utils.loop import runLoop, getFps
from utils.helpers import importOrFallback
from conf import Config

importOrFallback "systems/network"


proc run*(config: Config) =
  logging.debug("Starting server")
 
  network.init(port=config.network.port)

  runLoop(
    updatesPerSecond = 30,
    maxFrequencyCallback = proc(dt: float): bool {.closure.} = network.poll(); return true,
  )

  logging.debug("Server shutdown")
