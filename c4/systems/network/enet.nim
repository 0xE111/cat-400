from "../network" import NetworkSystem
from logging import nil


type
  EnetNetworkSystem* = object of NetworkSystem


method init*(self: ref EnetNetworkSystem) =
  logging.debug("EnetNetworkSystem init")

method update*(self: ref EnetNetworkSystem, dt: float): bool =
  result = true
