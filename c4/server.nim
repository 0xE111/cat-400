from logging import nil

import systems.network
from utils.loop import runLoop, getFps


type
  Config* = tuple[
    port: uint16,
  ]


proc run*(config: Config) =
  logging.debug("Starting server")
 
  var networkClient = network.Client()
  networkClient.init(port=config.port)

  runLoop(
    updatesPerSecond = 30,
    # fixedFrequencyHandlers = @[
    #   proc(dt: float): bool {.closure.} = return true,
    # ],
    maxFrequencyHandlers = @[
      proc(dt: float): bool {.closure.} = networkClient.poll(); return true,
    ]
  )
