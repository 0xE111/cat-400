import math

import c4/entities
import c4/threads
import c4/logging
import c4/lib/ogre/ogre
import c4/lib/ode/ode
import c4/systems/physics/ode

import ../systems/network
import ../systems/video
import ../systems/physics
import ../messages
import ../threads
import ../utils

method receive*(self: ref ServerNetworkSystem, message: ref PlayerRotateMessage) =
  message.send(physicsThread)

method process*(self: ref physics.PhysicsSystem, message: ref PlayerRotateMessage) =

  # get current rotation quaternion
  let qCurrent = self.player[ref physics.Physics].body.bodyGetQuaternion()[]

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

  self.player[ref physics.Physics].body.bodySetQuaternion(qFinal)
  (ref EntityRotateMessage)(entity: self.player, quaternion: qFinal).send(networkThread)

method receive*(self: ref ClientNetworkSystem, message: ref EntityRotateMessage) =
  message.entity = self.entitiesMap[message.entity]
  message.send(videoThread)

method process*(self: ref VideoSystem, message: ref EntityRotateMessage) =
  message.entity[ref Video].node.setOrientation(
    message.quaternion[0],
    message.quaternion[1],
    message.quaternion[2],
    message.quaternion[3],
  )

method receive*(self: ref ServerNetworkSystem, message: ref PlayerMoveMessage) =
  message.send(physicsThread)

method process*(self: ref physics.PhysicsSystem, message: ref PlayerMoveMessage) =

  let playerPhysics = self.player[ref physics.Physics]

  # calculate selected direction as a result of yaw on (0, 0, -1) vector
  let direction: array[3, float] = [-sin(message.yaw) , 0.0, -cos(message.yaw)]

  # get current rotation matrix and apply it to selected direction
  let rotation = playerPhysics.body.bodyGetRotation()[]
  let finalDirection: array[3, float] = [
    rotation[0] * direction[0] + rotation[1] * direction[1] + rotation[2] * direction[2],
    rotation[4] * direction[0] + rotation[5] * direction[1] + rotation[6] * direction[2],
    rotation[8] * direction[0] + rotation[9] * direction[1] + rotation[10] * direction[2],
  ]

  const walkSpeed = 5 * 1000 / 60 / 60
  self.player[ref physics.Physics].body.bodySetLinearVel(
    finalDirection[0] * walkSpeed,
    finalDirection[1] * walkSpeed,
    finalDirection[2] * walkSpeed,
  )

  # playerEntity[ref physics.Physics].startMovement()
