import c4/systems/network/enet
import c4/utils/stringify

import ../messages


type
  ClientNetworkSystem* = object of enet.ClientNetworkSystem
  ServerNetworkSystem* = object of enet.ServerNetworkSystem


strMethod(ClientNetworkSystem, fields=false)
strMethod(ServerNetworkSystem, fields=false)


# redefine network system methods below
