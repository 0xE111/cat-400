import logging
import strformat

import "../../../config"
import "../../../core/states"
import "../../../core/messages"
import "../../../core/entities"
import "../../../systems"
import "../../../systems/network/enet"

import "../messages" as action_messages


type
  ActionNetworkSystem* = object of NetworkSystem


method process(self: ref ActionNetworkSystem, message: ref CreateEntityMessage) =
  procCall ((ref NetworkSystem)self).process(message)
  message.send(config.systems.video)

method process(self: ref ActionNetworkSystem, message: ref PhysicsMessage) =
  procCall ((ref NetworkSystem)self).process(message)
  message.send(config.systems.video)

# TODO: DisconnectMessage
