from logging import debug
from utils.loop import runLoop
from utils.loading import load
from conf import Config

load "core/messages"
load "systems/network"
load "systems/video"

import systems.input


proc run*(config: Config) =
  logging.debug("Starting client")

  network.init()
  network.connect((host: "localhost", port: config.network.port))

  video.init(
    title=config.title,
    windowConfig=config.video.window,
  )

  var input = config.systems.input
  input.init()

  runLoop(
    updatesPerSecond = 30,
    fixedFrequencyCallback = proc(dt: float): bool =
      video.update(dt)
      messages.queue.flush()
      return true,
    maxFrequencyCallback = proc(dt: float): bool =
      input.update(dt)
      network.poll()
      return true,
  )

  logging.debug("Client shutdown")
  video.release()
