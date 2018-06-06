import logging
import strformat

import "../../../config"
import "../../../core/states"
import "../../../core/messages"
import "../../../systems"
import "../../../systems/network/enet"

import "../../default/messages" as default_messages
import "../../default/handlers" as default_handlers
import "../../default/states" as default_states

import "../messages" as action_messages


type
  ActionNetworkSystem* = object of NetworkSystem


method store(self: ref ActionNetworkSystem, message: ref ConnectMessage) =
  # by default network system sends all local incoming messages
  # however, we want to store and process ConnectMessage
  procCall ((ref System)self).store(message)

method process(self: ref ActionNetworkSystem, message: ref CreateEntityMessage) =
  procCall ((ref NetworkSystem)self).process(message)
  message.send(config.systems.video)

method process(self: ref ActionNetworkSystem, message: ref PhysicsMessage) =
  procCall ((ref NetworkSystem)self).process(message)
  message.send(config.systems.video)

# TODO: DisconnectMessage
