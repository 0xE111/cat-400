import config
import core.states
import logging
from utils.loop import runLoop
import strformat

import systems
import systems.network.enet
import systems.physics.ode
import systems.video.horde3d
import systems.input.sdl


proc initServer*() =
  logging.debug "Initializing server"
  
  # set up network and physics system for server
  if config.systems.network.isNil:
    config.systems.network = new(NetworkSystem)
  config.systems.network.init()
  logging.info &"Server listening at localhost:{config.settings.network.port}"

  if config.systems.physics.isNil:
    config.systems.physics = new(PhysicsSystem)
  config.systems.physics.init()

proc initClient*() =
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

proc run*() =
  logging.debug "Starting process"

  if config.mode == Mode.server:
    initServer()
    runLoop(
      updatesPerSecond = 30,
      fixedFrequencyCallback = proc(dt: float): bool =  # TODO: maxFrequencyCallback?
        config.systems.network.update(dt)
        config.systems.physics.update(dt)
        true  # TODO: how to quit?
    )
  else:
    initClient()
    runLoop(
      updatesPerSecond = 30,
      fixedFrequencyCallback = proc(dt: float): bool =  # TODO: maxFrequencyCallback?
        config.systems.network.update(dt)
        config.systems.input.update(dt)
        config.systems.video.update(dt)
        true  # TODO: how to quit?
    )

  # TODO: GC supports real-time mode which this library makes use of. It means the GC will never run during game frames and will use fixed amount of frame idle time to collect garbage. This leads to no stalls and close to zero compromise on performance comparing to native languages with manual memory management.

  logging.debug "Finishing process"
