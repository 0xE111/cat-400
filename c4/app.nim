import config
import core.states
from logging import debug
from utils.loop import runLoop

import systems.network as network_system
import systems.physics as physics_system
import systems.video as video_system
import systems.input as input_system

import defaults.states as default_states


# aliases
let
  network = config.systems.network.instance
  physics = config.systems.physics.instance
  video = config.systems.video.instance
  input = config.systems.input.instance


method update(self: ref State, dt: float): bool {.base, inline.} = true
method update*(self: ref FinalState, dt: float): bool {.inline.} = false

# ---- server ----
method onEnter*(self: ref InitialServerState) =
  logging.debug "Initializing server"
  
  network.init(port=config.systems.network.port)
  physics.init()

method update*(self: ref ServerState, dt: float): bool =
  network.update(dt)
  true

method update*(self: ref RunningServerState, dt: float): bool =
  network.update(dt)
  physics.update(dt)
  true

# ---- client ----
method onEnter*(self: ref InitialClientState) =
  logging.debug "Initializing client"

  network.init()
  input.init()
  video.init(
    title=config.title,
    window=config.systems.video.window,
  )

  config.state.switch(new(RunningClientState))


method update*(self: ref RunningClientState, dt: float): bool =
  network.update(dt)
  input.update(dt)
  video.update(dt)
  true


# ---- general procs ----
proc run*(initialState: ref State) =
  logging.debug "Starting process"

  config.state.switch(initialState)
  runLoop(
    updatesPerSecond = 30,
    maxFrequencyCallback = proc(dt: float): bool =
      return config.state.update(dt),
  )

  logging.debug "Finishing process"
