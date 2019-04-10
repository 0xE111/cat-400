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
  assert not message.isLocal
  procCall self.as(ref System).store(message)


method process*(self: ref ActionServerNetworkSystem, message: ref PlayerRotateMessage) =
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


proc getPitchYaw(q: dQuaternion): tuple[yaw: float, pitch: float] =
  ## Convert quaternion as only yaw and pitch rotations

  # rotation in Euler angles
  let eul = q.eulFromQ()

  # get current yaw & pitch (as if it was without roll)
  let
    flip: bool = not(abs(eul.z) <= 0.001)

  result.yaw = if not flip: eul.y else: PI - eul.y
  result.pitch = if not flip: eul.x else: eul.x + (if eul.x < 0: PI else: -PI)


method process(self: ref ActionPhysicsSystem, message: ref PlayerRotateMessage) =
  let playerEntity = self.impersonationsMap[message.sender]

  # get current rotation quaternion
  let qCurrent = playerEntity[ref Physics].body.bodyGetQuaternion()[]

  # get current yaw and pitch
  let current = qCurrent.getPitchYaw()

  # calculate combined pitch and yaw
  let
    yaw = current.yaw + message.yaw
    pitch = max(min(current.pitch + message.pitch, PI/2 * 0.99), -PI/2 * 0.99)

  # convert PlayerRotateMessage relative angles to rotation quaternions
  var qYaw, qPitch: dQuaternion
  qYaw.qFromAxisAndAngle(0, 1, 0, yaw)
  qPitch.qFromAxisAndAngle(1, 0, 0, pitch)

  # multiply rotation quaternions and set result as new entity rotation quaternion
  var qFinal: dQuaternion
  qFinal.qMultiply0(qYaw, qPitch)

  playerEntity[ref Physics].body.bodySetQuaternion(qFinal)


method store*(self: ref ActionServerNetworkSystem, message: ref PlayerMoveMessage) =
  ## Allow server to store ``PlayerMoveMessage``
  assert not message.isLocal
  procCall self.as(ref System).store(message)


method process(self: ref ActionServerNetworkSystem, message: ref PlayerMoveMessage) =
  message.send(config.systems.physics)


# proc apply*(vector: (float, float, float), q: dQuaternion): (float, float, float) =
#   result[0] = vector[0] * (1 - 2 * q[2] * q[2] - 2 * q[3] * q[3]) +
#               vector[1] * 2 * (q[1] * q[2] + q[0] * q[3]) +
#               vector[2] * 2 * (q[1] * q[3] - q[0] * q[2])

#   result[1] = vector[0] * 2 * (q[1] * q[2] - q[0] * q[3]) +
#               vector[1] * (1 - 2 * q[1] * q[1] - 2 * q[3] * q[3]) +
#               vector[2] * 2 * (q[2] * q[3] + q[0] * q[1])

#   result[2] = vector[0] * 2 * (q[1] * q[3] + q[0] * q[2]) +
#               vector[1] * 2 * (q[2] * q[3] - q[0] * q[1]) +
#               vector[2] * (1 - 2 * q[1] * q[1] - 2 * q[2] * q[2])


method process(self: ref ActionPhysicsSystem, message: ref PlayerMoveMessage) =
  let playerEntity = self.impersonationsMap[message.sender]

  # get current position
  let position = playerEntity[ref Physics].body.bodyGetPosition()[]

  let angles = playerEntity[ref Physics].body.bodyGetQuaternion()[].getPitchYaw()

  let
    yaw = angles.yaw + message.yaw
    pitch = angles.pitch

  let
    x = cos(pitch) * -sin(yaw)
    y = sin(pitch)
    z = cos(pitch) * -cos(yaw)

  # # calculate selected direction as a result of yaw on (0, 0, -1) vector
  # let selectedDirection = (-sin(message.yaw) , 0.0, -cos(message.yaw))

  # # rotate selected direction using body's rotation quaternion
  # let direction = selectedDirection.apply(playerEntity[ref Physics].body.bodyGetQuaternion()[])

  # echo &"<<<<< Direction: {direction}"

  playerEntity[ref Physics].body.bodySetPosition(
    position[0] + x * 5,
    position[1] + y * 5,
    position[2] + z * 5,
  )
