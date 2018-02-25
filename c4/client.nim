from logging import nil
import systems.network
from utils.loop import runLoop


type
  Config* = tuple[]


proc run*(config: Config) =
  logging.debug("Starting client")

  network.init()
  var networkClient = network.Client()
  networkClient.init()
  
  runLoop(
      updatesPerSecond = 30,
      fixedFrequencyHandlers = @[
        proc(dt: float): bool = networkClient.update(dt),  # anonymous proc
      ], 
    )
