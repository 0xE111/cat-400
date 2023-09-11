import c4/systems/network/net

import ../messages


type
  ServerNetworkSystem* = object of net.ServerNetworkSystem

  ClientNetworkSystem* = object of net.ClientNetworkSystem
