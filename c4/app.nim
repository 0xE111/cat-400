import config
import logging
import utils.loop
import strformat

import systems
import systems.network.enet
import systems.physics.ode
import systems.video.horde3d
import systems.input.sdl


template initSystem(system: ref System, defaultSystemType: typedesc) =
  ## Shortcut to:
  ## - create default system (if custom is not defined)
  ## - init system
  ## - send ``SystemReady`` message to that system

  if system.isNil:
    system = new(defaultSystemType)
  
  system.init()
  new(SystemReadyMessage).send(system)


proc initServer() =
  logging.debug "Initializing server"
  
  initSystem(config.systems.network, NetworkSystem)
  initSystem(config.systems.physics, PhysicsSystem)

proc initClient() =
  logging.debug "Initializing client"

  initSystem(config.systems.network, NetworkSystem)
  initSystem(config.systems.input, InputSystem)
  initSystem(config.systems.video, VideoSystem)

proc run*() =
  ## This proc initializes all systems and runs game loop.

  logging.debug "Starting process"

  try:
    if mode == Mode.server:
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
  except:
    # log any exception from client/server before dying
    logging.fatal &"Exception: {getCurrentExceptionMsg()}"
    raise


  # TODO: GC supports real-time mode which this library makes use of. It means the GC will never run during game frames and will use fixed amount of frame idle time to collect garbage. This leads to no stalls and close to zero compromise on performance comparing to native languages with manual memory management.

  logging.debug "Finishing process"
