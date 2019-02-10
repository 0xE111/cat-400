import logging
import strformat
import tables

import ../../../core/messages
import ../../../core/entities
import ../../../systems
import ../../../config
import ../../../systems/network/enet
import ../../../systems/physics/ode
import ../../../wrappers/ode/ode as ode_wrapper

import ../systems/network as action_network
import ../systems/physics as action_physics
import ../messages as action_messages


method store*(self: ref ActionServerNetworkSystem, message: ref PlayerRotateMessage) =
  ## Allow server to store ``PlayerRotateMessage``
  if not message.isLocal:
    procCall self.as(ref System).store(message)

  else:
    logging.warn &"{self} cannot send {message}, discarding"


method process(self: ref ActionServerNetworkSystem, message: ref PlayerRotateMessage) =
  message.send(config.systems.physics)


method process(self: ref ActionPhysicsSystem, message: ref PlayerRotateMessage) =
  let playerEntity = self.impersonationsMap[message.sender]

  var quaternion = playerEntity[ref Physics].body.bodyGetQuaternion()[]
  logging.debug &"Rotation quaternion [old]: {quaternion}"
  playerEntity[ref Physics].body.bodySetQuaternion(quaternion)

  # quaternion = playerEntity[ref Physics].body.bodyGetQuaternion()[]
  # logging.debug &"Rotation quaternion [new]: {quaternion}"
