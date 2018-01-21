import logging
import network
import ../wrappers/enet/[
  enet,
  nimenet
]


template debug(message: string) =
  logging.debug("Enet network system: " & message)


type
  EnetNetworkSystem* = object of NetworkSystem
    host: ptr enet.Host


method init*(self: ref EnetNetworkSystem, kind: NetworkSystemKind) =
  debug("Init")
  nimenet.init()

  if kind == NetworkSystemKind.Server:
    self.host = nimenet.startServer()
    debug("Server started: " & $self.host)
  # else:
  #   nimenet.startClient()


method update*(self: ref EnetNetworkSystem, dt: float): bool =
  result = true
