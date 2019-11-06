import tables

import c4/systems
import c4/systems/network/enet
import c4/utils/stringify

import ../messages


type
  ClientNetworkSystem* = object of enet.ClientNetworkSystem
  ServerNetworkSystem* = object of enet.ServerNetworkSystem


strMethod(ClientNetworkSystem, fields=false)
strMethod(ServerNetworkSystem, fields=false)


method store*(self: ref ClientNetworkSystem, message: ref ResetSceneMessage) =
  procCall self.as(ref NetworkSystem).store(message)  # send message


method store*(self: ref ServerNetworkSystem, message: ref ResetSceneMessage) =
  procCall self.as(ref System).store(message)  # store message


method process*(self: ref ServerNetworkSystem, message: ref ResetSceneMessage) =
  # When network receives ``ResetSceneMessage``, it forwards the message to physics system
  procCall self.as(ref enet.ServerNetworkSystem).process(message)
  message.send("physics")
