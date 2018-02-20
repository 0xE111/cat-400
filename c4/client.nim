from logging import nil
import systems.network
from utils.loop import runLoop


type
  Config* = tuple[]


proc run*(config: Config) =
  logging.debug("Starting client")
  var network = NetworkClient()
  network.init()
  
  runLoop(
      updatesPerSecond = 30,
      fixedFrequencyHandlers = @[
        proc(dt: float): bool = network.update(dt),  # anonymous proc
      ], 
    )