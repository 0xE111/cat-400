import logging
import strformat
import tables

import config
import utils/loop

import systems


proc run*() =
  ## This proc initializes all systems and runs game loop.

  logging.debug &"Starting {config.mode} process"

  config.systems = if mode == Mode.server: config.serverSystems else: config.clientSystems

  try:
    for systemName, system in config.systems.pairs:
      logging.debug &"Initializing {systemName}"
      system.init()
      new(SystemReadyMessage).send(system)

    logging.debug "Starting main loop"

    runLoop(
      updatesPerSecond = 30,
      fixedFrequencyCallback = proc(dt: float): bool =  # TODO: maxFrequencyCallback?
        for system in config.systems.values():
          system.update(dt)
        true  # TODO: how to quit?
    )

  except Exception as exc:
    # log any exception from client/server before dying
    logging.fatal &"Exception: {exc.msg}\n{exc.getStackTrace()}"
    raise

  # TODO: GC supports real-time mode which this library makes use of. It means the GC will never run during game frames and will use fixed amount of frame idle time to collect garbage. This leads to no stalls and close to zero compromise on performance comparing to native languages with manual memory management.

  logging.debug "Finishing process"
