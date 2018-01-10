from utils.loop import runLoop
from utils.state import State, switch
from logging import nil

import systems.network


type
  ServerConfig* = tuple[
    network: ref NetworkSystem,
  ]

  None* = object of State
  Loading* = object of State
  Running* = object of State

  Server* = object of RootObj
    state: ref State
    config: ServerConfig

method switch(self: var ref State, newState: ref Loading, instance: ref Server) =
  if self of ref None:
    self = newState

    logging.debug("Server is Loading")
    instance.config.network.init()

    self.switch(new(ref Running), instance=instance)

method switch(self: var ref State, newState: ref Running, instance: ref Server) =
  if self of ref Loading:
    self = newState
    logging.debug("Server is Running")

    runLoop(
      updatesPerSecond = 30,
      fixedFrequencyHandlers = @[
        proc(dt: float): bool = instance.config.network.update(dt),  # anonymous proc
      ], 
    )

proc run*(self: ref Server, config: ServerConfig) =
  logging.debug("Starting server")
  self.config = config
  self.state = new(ref None)
  self.state.switch(new(ref Loading), instance=self)
