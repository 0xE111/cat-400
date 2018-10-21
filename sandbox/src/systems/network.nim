import logging
import strformat

import c4/config
import c4/systems as c4_systems
import c4/utils/loading
import c4/systems/network/enet
import c4/core/entities
import c4/presets/action/messages as action_messages
import c4/presets/action/systems/network

import ../messages


type
  SandboxNetworkSystem* = object of ActionNetworkSystem


method store*(self: ref SandboxNetworkSystem, message: ref ResetSceneMessage) =
  if mode == client:
    procCall self.as(ref NetworkSystem).store(message)  # send message

  else:
    procCall self.as(ref System).store(message)  # store message

method process*(self: ref SandboxNetworkSystem, message: ref ResetSceneMessage) =
  # When network receives ``ResetSceneMessage``, it forwards the message to physics system
  assert mode == server
  procCall self.as(ref ActionNetworkSystem).process(message)

  message.send(systems.physics)

method store*(self: ref SandboxNetworkSystem, message: ref SetPositionMessage) =
  if mode == client:  # TODO:r use another way to separate client and server code
    procCall self.as(ref System).store(message)  # store message

  else:
    procCall self.as(ref NetworkSystem).store(message)  # send message

method process*(self: ref SandboxNetworkSystem, message: ref SetPositionMessage) =
  message.send(systems.video)
