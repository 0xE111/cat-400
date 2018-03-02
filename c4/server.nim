from logging import nil

from utils.loop import runLoop, getFps
from utils.helpers import importString
from modules import networkModule

importString(networkModule, "network")


type
  Config* = tuple[
    port: uint16,
  ]


proc run*(config: Config) =
  logging.debug("Starting server")
 
  var networkClient = network.Client()
  networkClient.init(port=config.port)

  runLoop(
    updatesPerSecond = 30,
    # fixedFrequencyHandlers = @[
    #   proc(dt: float): bool {.closure.} = return true,
    # ],
    maxFrequencyHandlers = @[
      proc(dt: float): bool {.closure.} = networkClient.poll(); return true,
    ]
  )
