from logging import nil
import systems.network
from utils.loop import runLoop


type
  Config* = tuple[]

proc run*(config: Config) =
  logging.debug("Starting client")

  var networkClient = network.Client()
  networkClient.init()
  networkClient.connect((host: "localhost", port: 11477'u16))

  runLoop(
      updatesPerSecond = 30,
      maxFrequencyHandlers = @[
        proc(dt: float): bool {.closure.} = networkClient.poll(); return true,
      ]
    )
