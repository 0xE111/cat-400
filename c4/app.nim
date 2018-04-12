import config
import core.states
from logging import debug
from utils.loop import runLoop
from strformat import `&`

import systems
import systems.network as network_system
import systems.physics as physics_system
import systems.video as video_system
import systems.input as input_system

import defaults.states as default_states


method update(self: ref State, dt: float): bool {.base, inline.} = true
method update*(self: ref FinalState, dt: float): bool {.inline.} = false

# ---- server ----
method onEnter*(self: ref InitialServerState) =
  logging.debug "Initializing server"
  
  if config.systems.network.isNil:
    config.systems.network = new(NetworkSystem)
  config.systems.network.init()

  if config.systems.physics.isNil:
    config.systems.physics = new(PhysicsSystem)
  config.systems.physics.init()

  logging.info &"Server listening at localhost:{config.settings.network.port}"
  config.state.switch(new(RunningServerState))

method update*(self: ref ServerState, dt: float): bool =
  config.systems.network.update(dt)
  true

method update*(self: ref RunningServerState, dt: float): bool =
  config.systems.network.update(dt)
  config.systems.physics.update(dt)
  true

# ---- client ----
method onEnter*(self: ref InitialClientState) =
  logging.debug "Initializing client"

  config.settings.network.serverMode = false  # init network as a client
  if config.systems.network.isNil:
    config.systems.network = new(NetworkSystem)
  config.systems.network.init()

  if config.systems.input.isNil:
    config.systems.input = new(InputSystem)
  config.systems.input.init()

  if config.systems.video.isNil:
    config.systems.video = new(VideoSystem)
  config.systems.video.init()

  config.state.switch(new(RunningClientState))


method update*(self: ref RunningClientState, dt: float): bool =
  config.systems.network.update(dt)
  config.systems.input.update(dt)
  config.systems.video.update(dt)
  true


# ---- general procs ----
proc run*(initialState: ref State) =
  logging.debug "Starting process"

  config.state.switch(initialState)
  runLoop(
    updatesPerSecond = 30,
    fixedFrequencyCallback = proc(dt: float): bool =  # TODO: mexFrequencyCallback?
      return config.state.update(dt),
  )

  logging.debug "Finishing process"