import tables

import ../../../core/messages
import ../../../core/entities
import ../../../systems/network/enet
import ../../../utils/stringify


type
  ActionClientNetworkSystem* = object of ClientNetworkSystem
  ActionServerNetworkSystem* = object of ServerNetworkSystem


strMethod(ActionClientNetworkSystem, fields=false)
strMethod(ActionServerNetworkSystem, fields=false)
