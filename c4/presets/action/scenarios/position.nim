import logging
import strformat

import ../../../config
import ../../../core/messages
import ../../../core/entities
import ../../../systems as c4_systems
import ../../../systems/video/horde3d as horde3d_video
import ../../../systems/network/enet as enet_network
import ../systems/video
import ../systems/input
import ../systems/network
import ../messages as action_messages

import ../../../wrappers/horde3d/horde3d
import ../../../wrappers/horde3d/horde3d/helpers


method process*(self: ref ActionClientNetworkSystem, message: ref SetPositionMessage) =
  procCall self.as(ref ClientNetworkSystem).process(message)
  message.send(systems.video)


method process(self: ref ActionVideoSystem, message: ref SetPositionMessage) =
  if not message.entity.has(ref Video):
    logging.warn &"{self} received {message}, but has no Video component"
    # raise newException(LibraryError, "Shit im getting errors")
    # TODO: When client just connected to server, the server still may broadcast some messages
    # before syncing world state with client. When these messages reach client, it doesn't have
    # corresponding components yet, thus won't be able to process these messages and fail.
    return

  let
    node = message.entity[ref Video].node
    curTransform = node.getTransform()

  node.setNodeTransform(
    message.x, message.y, message.z,
    curTransform.rx, curTransform.ry, curTransform.rz,
    curTransform.sx, curTransform.sy, curTransform.sz,
  )


method process*(self: ref ActionClientNetworkSystem, message: ref SetRotationMessage) =
  ## Forward the message to video system
  procCall self.as(ref ClientNetworkSystem).process(message)
  message.send(systems.video)


method process*(self: ref ActionVideoSystem, message: ref SetRotationMessage) =
      # let
      #   rMat = self.body.bodyGetRotation()[]  # rotation matrix
      #   epsilon = 0.000002

      # var alpha, beta, gamma: float

      # logging.debug &"Rotation matrix: {rMat}"
      # # Horde3d order is YXZ(vec)
      # let
      #   m33 = rMat.get(3, 3)
      #   m13 = rMat.get(1, 3)
      #   cy = sqrt(m33 * m33 + m13 * m13)

      # if cy > 16 * epsilon:
      #   gamma = arctan2(rMat.get(2, 1), rMat.get(2, 2))
      #   beta = arctan2(-rMat.get(2, 3), cy)
      #   alpha = arctan2(rMat.get(1, 3), rMat.get(3, 3))
      # else:
      #   gamma = arctan2(-rMat.get(1, 2), rMat.get(1, 1))
      #   beta = arctan2(-rMat.get(2, 3), cy)
      #   alpha = 0

      # logging.debug &"Euler angles: yaw={alpha.radToDeg:.3f}, pitch={beta.radToDeg:.3f}, roll={gamma.radToDeg:.3f}"

  let
    node = message.entity[ref Video].node
    curTransform = node.getTransform()

  node.setNodeTransform(
    curTransform.tx, curTransform.ty, curTransform.tz,
    curTransform.rx,  # (curTransform.rx - (message.pitch / 8).cfloat).max(-85).min(85),  # here we limit camera pitch
    curTransform.ry - 5.cfloat,
    curTransform.rz,
    curTransform.sx, curTransform.sy, curTransform.sz,
  )