from logging import nil

from server import ServerConfig

from systems.network import NetworkSystem
from systems.network.enet import EnetNetworkSystem


type
  Mode* {.pure.} = enum
    default, server

  ClientConfig* = tuple[
    network: ref NetworkSystem,
  ]

  # TODO: get rid of `Config` type and just use auto type when initializing `config` var
  Config* = tuple[
    version: string,
    logLevel: logging.Level,
    mode: Mode,
    server: ServerConfig,
    client: ClientConfig,    
  ]

var
  config*: Config = (
    version: "0.0",
    logLevel: logging.Level.lvlWarn,
    mode: Mode.default,
    server: (
      network: new(ref EnetNetworkSystem),
    ),
    client: (
      network: new(ref EnetNetworkSystem),
    )
  )


# when declared(strutils.find):
#   discard

# when compiles($foo):
#   discard

# - Init proc
# - Conditional import