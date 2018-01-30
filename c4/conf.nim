from logging import nil

from server import ServerConfig

from systems.network import Network
from systems.network_enet import EnetNetwork


type
  Mode* {.pure.} = enum
    default, server

  ClientConfig* = tuple[
    network: ref Network,
  ]

  # TODO: get rid of `Config` type and just use auto type when initializing `config` var
  Config* = tuple[
    # may use currentSourcePath()
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
      network: new(ref EnetNetwork),
      port: 11477'u16,
    ),
    client: (
      network: new(ref EnetNetwork),
    )
  )


# when declared(strutils.find):
#   discard

# when compiles($foo):
#   discard

# - Init proc
# - Conditional import