import config
import core.states
from logging import debug
from utils.loop import runLoop
from strformat import `&`

import systems
import systems.network.enet
import systems.physics.ode
import systems.video.horde3d
import systems.input.sdl

import presets.default.states as default_states


method update(self: ref State, dt: float): bool {.base, inline.} = true  # every state does not finish loop but does nothin
method update(self: ref FinalState, dt: float): bool {.inline.} = false  # but FinalState breaks the loop by returning false


# ---- server ----
method onEnter*(self: ref InitialServerState) =
  logging.debug "Initializing server"
  
  # set up network and physics system for server
  if config.systems.network.isNil:
    config.systems.network = new(NetworkSystem)
  config.systems.network.init()

  if config.systems.physics.isNil:
    config.systems.physics = new(PhysicsSystem)
  config.systems.physics.init()

  logging.info &"Server listening at localhost:{config.settings.network.port}"
  config.state.switch(new(RunningServerState))

method update*(self: ref ServerState, dt: float): bool =
  # by defalut, all server states update only network
  config.systems.network.update(dt)
  true

method update*(self: ref RunningServerState, dt: float): bool =
  # running server state updates network and physics
  config.systems.network.update(dt)
  config.systems.physics.update(dt)
  true

# ---- client ----
method onEnter*(self: ref InitialClientState) =
  logging.debug "Initializing client"

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

method update(self: ClientState, dt: float): bool =
  config.systems.network.update(dt)
  true

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
    fixedFrequencyCallback = proc(dt: float): bool =  # TODO: maxFrequencyCallback?
      return config.state.update(dt),
  )
  # TODO: GC supports real-time mode which this library makes use of. It means the GC will never run during game frames and will use fixed amount of frame idle time to collect garbage. This leads to no stalls and close to zero compromise on performance comparing to native languages with manual memory management.

  logging.debug "Finishing process"
