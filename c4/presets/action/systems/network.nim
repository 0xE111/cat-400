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
  ## When new peer connects, we want to create a corresponding entity, thus we forward this message to physics system.
  ## 
  ## Also we need to handle connection on client side, that's why we send this message to video system as well.
  procCall ((ref NetworkSystem)self).process(message)

  if message.isExternal:
    if config.mode == server:
      message.send(config.systems.physics)
    elif config.mode == client:
      message.send(config.systems.video)

method process*(self: ref ActionNetworkSystem, message: ref DisconnectMessage) =
  ## When peer disconnects, we want to delete corresponding entity, thus we forward this message to physics system.
  ## 
  ## Also we need to handle disconnection on client side, that's why we send this message to video system as well.
  procCall ((ref NetworkSystem)self).process(message)

  if message.isExternal:
    if config.mode == server:
      message.send(config.systems.physics)
    elif config.mode == client:
      message.send(config.systems.video)
