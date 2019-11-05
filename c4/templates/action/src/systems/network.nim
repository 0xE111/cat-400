import tables

import c4/messages
import c4/systems/network/enet
import c4/utils/stringify


type
  ClientNetworkSystem* = object of enet.ClientNetworkSystem
  ServerNetworkSystem* = object of enet.ServerNetworkSystem


strMethod(ClientNetworkSystem, fields=false)
strMethod(ServerNetworkSystem, fields=false)
