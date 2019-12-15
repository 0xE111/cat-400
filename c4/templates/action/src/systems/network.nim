import tables

import c4/threads
import c4/systems/network/enet
import c4/utils/stringify

import ../messages


type
  ClientNetworkSystem* = object of enet.ClientNetworkSystem
  ServerNetworkSystem* = object of enet.ServerNetworkSystem


strMethod(ClientNetworkSystem, fields=false)
strMethod(ServerNetworkSystem, fields=false)


method processRemote*(self: ServerNetworkSystem, message: ref ResetSceneMessage) =
  # When network receives ``ResetSceneMessage``, it forwards the message to physics system
  message.send("physics")
