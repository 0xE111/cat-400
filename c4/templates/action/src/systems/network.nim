import tables

import c4/threads
import c4/systems/network/enet
import c4/utils/stringify

import ../messages


type
  ClientNetworkSystem* = object of EnetClientNetworkSystem
  ServerNetworkSystem* = object of EnetServerNetworkSystem


method processRemote*(self: ref ServerNetworkSystem, message: ref ResetSceneMessage) =
  # When network receives ``ResetSceneMessage``, it forwards the message to physics system
  message.send("physics")
