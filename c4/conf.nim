from server import ServerConfig

from systems.network import NetworkSystem
from systems.network.enet import EnetNetworkSystem


type
  ClientConfig* = tuple[
    network: ref NetworkSystem,
  ]

  Config* = tuple[
    version: string,
    server: ServerConfig,
    client: ClientConfig,    
  ]

var
  config*: Config = (
    version: "0.0",
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