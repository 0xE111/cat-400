from logging import nil

import systems.network
from utils.loop import runLoop


type
  Config* = tuple[
    port: uint16,
  ]


proc run*(config: Config) =
  logging.debug("Starting server")
 
  var network = NetworkServer()
  network.init(port=config.port)

  runLoop(
    updatesPerSecond = 30,
    fixedFrequencyHandlers = @[
        proc(dt: float): bool = network.update(dt),
      ],
  )
