from logging import nil

import systems.network
from utils.loop import runLoop, getFps


type
  Config* = tuple[
    port: uint16,
  ]


proc run*(config: Config) =
  logging.debug("Starting server")
 
  var networkConnection = Connection()
  networkConnection.init(port=config.port)

  runLoop(
    updatesPerSecond = 30,
    maxFrequencyHandlers = @[
      proc(dt: float): bool = networkConnection.poll(); logging.debug("NW polled @ fps " & $getFps(dt)); return true,
    ]
  )
