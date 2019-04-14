import logging
import strformat
import tables

import c4/config
import c4/systems as systems_module
import c4/utils/loading
import c4/systems/network/enet
import c4/core/entities
import c4/presets/action/messages as action_messages
import c4/presets/action/systems/network
import c4/utils/stringify

import ../messages


type
  SandboxClientNetworkSystem* = object of ActionClientNetworkSystem
  SandboxServerNetworkSystem* = object of ActionServerNetworkSystem


strMethod(SandboxClientNetworkSystem, fields=false)
strMethod(SandboxServerNetworkSystem, fields=false)


method store*(self: ref SandboxClientNetworkSystem, message: ref ResetSceneMessage) =
  procCall self.as(ref NetworkSystem).store(message)  # send message


method store*(self: ref SandboxServerNetworkSystem, message: ref ResetSceneMessage) =
  procCall self.as(ref System).store(message)  # store message


method process*(self: ref SandboxServerNetworkSystem, message: ref ResetSceneMessage) =
  # When network receives ``ResetSceneMessage``, it forwards the message to physics system
  procCall self.as(ref ActionServerNetworkSystem).process(message)
  message.send(systems["physics"])
