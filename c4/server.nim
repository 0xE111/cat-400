from logging import debug
from utils.loop import runLoop
from conf import config
from systems.network as network_module import NetworkSystem, init, update
from systems.physics as physics_module import PhysicsSystem, init, update, Physics

import core.entities
import core.messages, core.messages.builtins
import core.states


type
  ServerState* = object of State

  InitialState* = object of ServerState
  LoadingState* = object of ServerState
  RunningState* = object of ServerState
  FinishingState* = object of ServerState

var
  state* = new(ServerState)
  network: ref NetworkSystem
  physics: ref PhysicsSystem


method update*(self: ref ServerState, dt: float): bool {.base, inline.} = false
  

# initial state
method onEnter*(self: ref InitialState) =
  logging.debug "Initializing server"
  network = config.systems.network.instance
  network.init(port=config.systems.network.port)

  physics = config.systems.physics.instance
  physics.init()

method update*(self: ref InitialState, dt: float): bool =
  network.update(dt)
  true

# loading state
method update*(self: ref LoadingState, dt: float): bool =
  network.update(dt)
  true

# running state
method update*(self: ref RunningState, dt: float): bool =
  network.update(dt)
  physics.update(dt)
  true

# finishing state
method update*(self: ref FinishingState, dt: float): bool =
  false


proc run*(initialState: ref ServerState) =
  logging.debug "Starting server"
  state.switch(initialState)
  runLoop(
    updatesPerSecond = 30,
    maxFrequencyCallback = proc(dt: float): bool =
      return state.update(dt),
  )
  logging.debug "Stopping server"
