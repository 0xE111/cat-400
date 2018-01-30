from utils.loop import runLoop
from utils.state import State, switch
from logging import nil

import systems.network


type
  ClientConfig* = tuple[
    network: ref Network,
  ]

  None* = object of State
  Loading* = object of State
  Running* = object of State

  Client* = object of RootObj
    state: ref State
    config: ClientConfig

let
  noneState = new(ref None)
  loadingState = new(ref Loading)
  runningState = new(ref Running)

method switch(self: var ref State, newState: ref Loading, instance: ref Client) =
  if self of ref None:
    self = newState

    logging.debug("Loading")
    instance.config.network.init(kind=nkClient)

method switch(self: var ref State, newState: ref Running, instance: ref Client) =
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

proc run*(self: ref Client, config: ClientConfig) =
  logging.debug("Starting client")
  self.config = config
  self.state = noneState
  self.state.switch(loadingState, instance=self)
  self.state.switch(runningState, instance=self)
