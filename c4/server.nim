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
    fixedFrequencyHandlers = @[
      proc(dt: float): bool {.closure.} = logging.debug("Server updated @ " & $getFps(dt) & " fps"); return true,
    ],
    maxFrequencyHandlers = @[
      proc(dt: float): bool {.closure.} = networkConnection.poll(); return true,
    ]
  )
