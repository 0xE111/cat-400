import logging
import strformat

import "../../../config"
import "../../../core/messages"
import "../../../core/entities"
import "../../../systems"
import "../../../systems/network/enet"

import physics


type
  ActionNetworkSystem* = object of NetworkSystem


method process(self: ref ActionNetworkSystem, message: ref CreateEntityMessage) =
  ## When network systems receives ``CreateEntityMessage``, it processes it and sends it to video system
  procCall ((ref NetworkSystem)self).process(message)
  message.send(config.systems.video)

method process(self: ref ActionNetworkSystem, message: ref MoveMessage) =
  procCall ((ref NetworkSystem)self).process(message)
  message.send(config.systems.video)

method process(self: ref ActionNetworkSystem, message: ref RotateMessage) =
  procCall ((ref NetworkSystem)self).process(message)
  message.send(config.systems.video)

method process*(self: ref ActionNetworkSystem, message: ref ConnectMessage) =
  ## When new peer connects, we want to create a corresponding entity,
  ## thus we forward this message to physics system
  procCall ((ref NetworkSystem)self).process(message)

  # if server receives external ``ConnectMessage`` - send it to physics system
  if message.isExternal and config.mode == server:
    message.send(config.systems.physics)

method process*(self: ref ActionNetworkSystem, message: ref DisconnectMessage) =
  ## When peer disconnects, we want to delete corresponding entity,
  ## thus we forward this message to physics system
  procCall ((ref NetworkSystem)self).process(message)

  # if server receives external ``DisconnectMessage`` - send it to physics system
  if message.isExternal and config.mode == server:
    message.send(config.systems.physics)
