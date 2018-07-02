import logging

import c4.config
import c4.systems
import c4.systems.network.enet
import c4.presets.action.systems.network

import "../messages"


type
  SandboxNetworkSystem* = object of ActionNetworkSystem


method process*(self: ref SandboxNetworkSystem, message: ref ResetSceneMessage) =
  # When network receives ``ResetSceneMessage``, it forwards the message to physics system
  procCall self.as(ref ActionNetworkSystem).process(message)

  message.send(config.systems.physics)
