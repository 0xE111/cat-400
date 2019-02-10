import logging
import strformat

# from ../../../core/entities
# from ../../../messages import EntityMessage
import ../../../config
from ../../../systems import `as`, send
import ../../../systems/network/enet

import ../systems/network as action_network
import ../messages as action_messages
import ../../../core/messages
import ../../../systems


method store*(self: ref ActionServerNetworkSystem, message: ref PlayerRotateMessage) =
  ## Allow server to store PlayerRotate message
  if not message.isLocal:
    procCall self.as(ref System).store(message)

  else:
    logging.warn &"{self} cannot send {message}, discarding"


method process(self: ref ActionServerNetworkSystem, message: ref PlayerRotateMessage) =
  message.send(config.systems.physics)


# method process(self: ref ActionNetworkSystem, message: ref PlayerMoveMessage) =
#   ## When local network system receives PlayerMoveMessage, send it to server's network
#   assert mode == server

#   procCall self.as(ref NetworkSystem).store(message)
#   # message.send(config.systems.video)


