import config
import core.states
from logging import debug
from utils.loop import runLoop

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
  
  config.systems.network.instance.init(port=config.systems.network.port)
  config.systems.physics.instance.init()

  config.state.switch(new(RunningServerState))

method update*(self: ref ServerState, dt: float): bool =
  config.systems.network.instance.update(dt)
  true

method update*(self: ref RunningServerState, dt: float): bool =
  config.systems.network.instance.update(dt)
  config.systems.physics.instance.update(dt)
  true

# ---- client ----
method onEnter*(self: ref InitialClientState) =
  logging.debug "Initializing client"

  config.systems.network.instance.init()
  config.systems.network.instance.connect(("localhost", config.systems.network.port))
  config.systems.input.instance.init()
  config.systems.video.instance.init(
    title=config.title,
    window=config.systems.video.window,
  )

  config.state.switch(new(RunningClientState))


method update*(self: ref RunningClientState, dt: float): bool =
  config.systems.network.instance.update(dt)
  config.systems.input.instance.update(dt)
  config.systems.video.instance.update(dt)
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
