# from logging import nil
# from utils.loop import runLoop
# from utils.states import State, None, switch
# from conf import config


# type
#   Loading* = object of State
#   Running* = object of State
#   Paused* = object of State

# var
#   state: ref State = new(ref None)  # TODO: add "not nil"

# let
#   network* = config.networkBackend

# proc update(dt:float): bool =
#   return not (state of ref None)

# proc start*() =
#   logging.debug("Process created")
#   state = state.switch(new(ref Loading))
#   runLoop(updatesPerSecond = 30, fixedFrequencyHandlers = @[update])
#   logging.debug("Process stopped")


# from utils.process import Process
from utils.loop import runLoop

import systems.network


type
  ServerConfig* = tuple[
    network: ref NetworkSystem,
  ]

  Server* = object of RootObj
    # state
    # config: ServerConfig


# proc init*(self: var Server, config: ServerConfig) =
#   self.config = config

proc run*(self: Server, config: ServerConfig) =
  config.network.init()

  # state switch

  runLoop(
    updatesPerSecond = 30,
    fixedFrequencyHandlers = @[
      proc(dt: float): bool = config.network.update(dt),  # anonymous proc
    ], 
  )
