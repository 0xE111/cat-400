from logging import nil
from utils.loop import runLoop
from utils.helpers import importString
import conf

importString(networkSystemPath, "network")
importString(videoSystemPath, "video")
importString(inputSystemPath, "input")


proc run*(config: Config) =
  logging.debug("Starting client")

  var networkClient = network.Client()
  networkClient.init()
  networkClient.connect((host: "localhost", port: config.network.port))

  video.init(
    title=config.title,
    windowConfig=config.video.window,
  )

  input.init(eventCallback=config.input.eventCallback)

  runLoop(
    updatesPerSecond = 30,
    fixedFrequencyCallback = proc(dt: float): bool {.closure.} = video.update(dt),
    maxFrequencyCallback = proc(dt: float): bool {.closure.} = networkClient.poll(); input.update(); return true,
  )

  logging.debug("Client shutdown")