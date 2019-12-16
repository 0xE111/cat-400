import c4/systems/network/enet

import ../messages


type
  ServerNetworkSystem* = object of EnetServerNetworkSystem
  ClientNetworkSystem* = object of EnetClientNetworkSystem
