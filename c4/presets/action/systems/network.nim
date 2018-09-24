import logging
import strformat

import ../../../config
import ../../../core/entities
import ../../../systems
import ../../../systems/network/enet

import physics
import ../messages


type
  ActionNetworkSystem* = object of NetworkSystem


method process(self: ref ActionNetworkSystem, message: ref CreateEntityMessage) =
  ## Sends message to video system.
  procCall self.as(ref NetworkSystem).process(message)
  message.send(config.systems.video)

method process(self: ref ActionNetworkSystem, message: ref PlayerMoveMessage) =
  ## Sends message to video system.
  procCall self.as(ref NetworkSystem).process(message)
  message.send(config.systems.video)

method process(self: ref ActionNetworkSystem, message: ref PlayerRotateMessage) =
  ## Sends message to video system.
  procCall self.as(ref NetworkSystem).process(message)
  message.send(config.systems.video)
