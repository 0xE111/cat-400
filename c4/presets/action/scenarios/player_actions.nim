import logging
import strformat
import tables
import math

import ../../../lib/ode/ode as ode_wrapper

import ../../../core/messages
import ../../../core/entities
import ../../../systems
import ../../../config
import ../../../systems/network/enet
import ../../../systems/physics/ode

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


proc eulFromR(r: dMatrix3): tuple[z, y, x: float] =
  # ZYXr case only
  let cy = sqrt(r[0] * r[0] + r[4] * r[4])
  if cy > 16 * 0.000002:
    result.x = arctan2(r[9], r[10])
    result.y = arctan2(-r[8], cy)
    result.z = arctan2(r[4], r[0])
  else:
    result.x = arctan2(-r[6], r[5])
    result.y = arctan2(-r[8], cy)
    result.z = 0


proc eulFromQ(q: dQuaternion): tuple[z, y, x: float] =
  # ZYXr case only

  # get rotation matrix
  var m: dMatrix3
  m.rfromQ(q)

  eulFromR(m)


method process(self: ref ActionPhysicsSystem, message: ref PlayerRotateMessage) =
  let playerEntity = self.impersonationsMap[message.sender]

  # get current rotation quaternion
  let qCurrent = playerEntity[ref Physics].body.bodyGetQuaternion()[]

  # current rotation in Euler angles
  let eulCurrent = qCurrent.eulFromQ()

  # get current yaw & pitch (as if it was without roll)
  let
    flip: bool = not(abs(eulCurrent.z) <= 0.001)
    currentYaw = if not flip: eulCurrent.y else: PI - eulCurrent.y
    currentPitch = if not flip: eulCurrent.x else: eulCurrent.x + (if eulCurrent.x < 0: PI else: -PI)

  # calculate combined pitch and yaw
  let
    yaw = currentYaw + message.yaw
    pitch = max(min(currentPitch + message.pitch, PI/2 * 0.99), -PI/2 * 0.99)

  # convert PlayerRotateMessage relative angles to rotation quaternions
  var qYaw, qPitch: dQuaternion
  qYaw.qFromAxisAndAngle(0, 1, 0, yaw)
  qPitch.qFromAxisAndAngle(1, 0, 0, pitch)

  # multiply rotation quaternions and set result as new entity rotation quaternion
  var qFinal: dQuaternion
  qFinal.qMultiply0(qYaw, qPitch)

  playerEntity[ref Physics].body.bodySetQuaternion(qFinal)
