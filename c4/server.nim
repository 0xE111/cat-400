from utils.loop import runLoop
from utils.state import State, switch
from logging import nil

import systems.network


type
  ServerConfig* = tuple[
    network: ref Network,
    port: uint16,
  ]

  None* = object of State
  Loading* = object of State
  Running* = object of State

  Server* = object of RootObj
    state: ref State
    config: ServerConfig

let
  noneState = new(ref None)
  loadingState = new(ref Loading)
  runningState = new(ref Running)

method switch(self: var ref State, newState: ref Loading, instance: ref Server) =
  if self of ref None:
    self = newState

    logging.debug("Loading")
    instance.config.network.init(kind=nkServer, port=instance.config.port)

method switch(self: var ref State, newState: ref Running, instance: ref Server) =
  if self of ref Loading:
    self = newState
    logging.debug("Running")

    runLoop(
      updatesPerSecond = 30,
      fixedFrequencyHandlers = @[
        proc(dt: float): bool = instance.config.network.update(dt),  # anonymous proc
        proc(dt: float): bool = instance.state of Running,  # check whether state is 'Running'
      ], 
    )

proc run*(self: ref Server, config: ServerConfig) =
  logging.debug("Starting server")
  self.config = config
  self.state = noneState
  self.state.switch(loadingState, instance=self)
  self.state.switch(runningState, instance=self)
