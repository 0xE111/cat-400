from logging import debug
from utils.loop import runLoop
from conf import config
from systems.network as network_module import NetworkSystem, init, update
from systems.physics as physics_module import PhysicsSystem, init, update, Physics
import core.entities
import core.messages, core.messages.builtins
from core.states import State, onLeave, onEnter, switch


type
  ServerState* = object of State

  InitialState* = object of ServerState
  LoadingState* = object of ServerState
  RunningState* = object of ServerState

var
  state* = new(ServerState)
  network: ref NetworkSystem
  physics: ref PhysicsSystem


method update*(self: ref ServerState, dt: float) {.base, inline.} = discard
  

# initial state
method onEnter*(self: ref InitialState) =
  logging.debug "Initializing server"
  network = config.systems.network.instance
  network.init(port=config.systems.network.port)

  physics = config.systems.physics.instance
  physics.init()

method update*(self: ref InitialState, dt: float) =
  network.update(dt)

# loading state
method update*(self: ref LoadingState, dt: float) =
  network.update(dt)

# running state
method update*(self: ref RunningState, dt: float) =
  network.update(dt)
  physics.update(dt)


proc run*() =
  logging.debug "Starting server"
  runLoop(
    updatesPerSecond = 30,
    maxFrequencyCallback = proc(dt: float): bool =
      state.update(dt)
      return true,
  )
