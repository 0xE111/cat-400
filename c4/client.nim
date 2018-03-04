from logging import nil
from utils.loop import runLoop
from utils.helpers import importString
import conf

importString(networkSystemPath, "network")
importString(videoSystemPath, "video")


proc run*(config: Config) =
  logging.debug("Starting client")

  var networkClient = network.Client()
  networkClient.init()
  networkClient.connect((host: "localhost", port: config.network.port))

  var videoSystem = video.Video()
  videoSystem.init(
    title=config.title,
    window=config.video.window,
  )

  runLoop(
      updatesPerSecond = 30,
      fixedFrequencyHandlers = @[

      ],
      maxFrequencyHandlers = @[
        proc(dt: float): bool {.closure.} = networkClient.poll(); return true,
      ]
    )

  logging.debug("Client shutdown")