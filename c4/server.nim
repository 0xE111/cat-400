from utils.loop import runLoop
from utils.state import State, switch
from logging import nil

import systems.network


type
  ServerConfig* = tuple[
    network: ref ServerNetwork,
    port: uint16,
  ]

  Server* = object of RootObj
    config: ServerConfig


proc run*(self: ref Server, config: ServerConfig) =
  logging.debug("Starting server")
  self.config = config

  self.config.network.init(port=self.config.port)
  
  runLoop(
    updatesPerSecond = 30,
    fixedFrequencyHandlers = @[
        proc(dt: float): bool = self.config.network.update(dt),  # anonymous proc
      ],
  )