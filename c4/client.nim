from logging import nil
from utils.loop import runLoop
from utils.helpers import importString
import conf

importString(networkSystemPath, "network")
importString(videoSystemPath, "video")
importString(inputSystemPath, "input")


var running* = true  # set this to false to stop client

proc run*(config: Config) =
  logging.debug("Starting client")

  network.init()
  network.connect((host: "localhost", port: config.network.port))

  video.init(
    title=config.title,
    windowConfig=config.video.window,
  )

  input.init(eventCallback=config.input.eventCallback)

  runLoop(
    updatesPerSecond = 30,
    fixedFrequencyCallback = proc(dt: float): bool {.closure.} = video.update(dt); return running,
    maxFrequencyCallback = proc(dt: float): bool {.closure.} = input.update(); network.poll(); return true,
  )

  logging.debug("Client shutdown")
  input.release()
  video.release()
