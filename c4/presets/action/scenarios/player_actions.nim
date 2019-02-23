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

  # get current rotation quaternion
  let qCurrent = playerEntity[ref Physics].body.bodyGetQuaternion()[]
  logging.debug &"Current rotation quaternion: {qCurrent}"

  # convert PlayerRotateMessage relative angles to rotation quaternions
  # TODO: reenable yaw
  var qY, qX: dQuaternion
  qFromAxisAndAngle(qY, 0, 1, 0, message.yaw)
  qFromAxisAndAngle(qX, 1, 0, 0, message.pitch)

  # multiply rotation quaternions and set result as new entity rotation quaternion
  var qFinal: dQuaternion = qCurrent
  qFinal.qMultiply0(qX, qFinal)
  qFinal.qMultiply0(qY, qFinal)
  playerEntity[ref Physics].body.bodySetQuaternion(qFinal)
