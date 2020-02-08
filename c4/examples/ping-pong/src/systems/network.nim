import c4/systems/network/enet


type
  ServerNetworkSystem* = object of EnetServerNetworkSystem
  ClientNetworkSystem* = object of EnetClientNetworkSystem
