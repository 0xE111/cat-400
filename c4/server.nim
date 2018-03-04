from logging import nil

from utils.loop import runLoop, getFps
from utils.helpers import importString
import conf

importString(networkSystemPath, "network")


proc run*(config: Config) =
  logging.debug("Starting server")
 
  var networkClient = network.Client()
  networkClient.init(port=config.network.port)

  runLoop(
    updatesPerSecond = 30,
    # fixedFrequencyHandlers = @[
    #   proc(dt: float): bool {.closure.} = return true,
    # ],
    maxFrequencyHandlers = @[
      proc(dt: float): bool {.closure.} = networkClient.poll(); return true,
    ]
  )

  logging.debug("Server shutdown")