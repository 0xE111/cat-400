import logging
import strformat

import "../../../config"
import "../../../core/states"
import "../../../core/messages"
import "../../../core/entities"
import "../../../systems"
import "../../../systems/network/enet"

import physics


type
  ActionNetworkSystem* = object of NetworkSystem


method process(self: ref ActionNetworkSystem, message: ref CreateEntityMessage) =
  # When network systems receives ``CreateEntityMessage``, it processes it and sends it to video system
  procCall ((ref NetworkSystem)self).process(message)
  message.send(config.systems.video)

method process(self: ref ActionNetworkSystem, message: ref MoveMessage) =
  procCall ((ref NetworkSystem)self).process(message)
  message.send(config.systems.video)

method process(self: ref ActionNetworkSystem, message: ref RotateMessage) =
  procCall ((ref NetworkSystem)self).process(message)
  message.send(config.systems.video)

# TODO: DisconnectMessage
