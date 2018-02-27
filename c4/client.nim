from logging import nil
import systems.network
from utils.loop import runLoop


type
  Config* = tuple[]


proc run*(config: Config) =
  logging.debug("Starting client")

  var networkConnection = network.Connection()
  networkConnection.init()
  
  runLoop(
      updatesPerSecond = 30,
      maxFrequencyHandlers = @[
        proc(dt: float): bool = networkConnection.poll(); return true,
      ]
    )
