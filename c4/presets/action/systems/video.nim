import tables
import strformat
import logging

import "../../../core/entities"
import "../../../systems/video/horde3d" as video

import "../../../wrappers/horde3d/horde3d"

import physics
import "../utils/matrix"
import "../messages"


type
  ActionVideoSystem* = object of VideoSystem


# method process(self: ref ActionVideoSystem, message: ref ActionPhysicsMessage) =
#   logging.debug &"Moving entity {message.entity} to {message.x} {message.y} {message.z}"
#   message.entity[ref Video][].transform(
#     translation=(message.x.float, message.y.float, message.z.float)
#   )

method process(self: ref ActionVideoSystem, message: ref PlayerRotateMessage) =
  # TODO: ugly
  var tx, ty, tz, rx, ry, rz, sx, sy, sz: cfloat
  self.camera.getNodeTransform(
    tx.addr, ty.addr, tz.addr,
    rx.addr, ry.addr, rz.addr,
    sx.addr, sy.addr, sz.addr,
  )

  self.camera.setNodeTransform(
    tx, ty, tz,
    (rx - (message.pitch / 8).cfloat).max(-85).min(85),  # here we limit camera pitch
    ry - (message.yaw / 8).cfloat,
    0.cfloat,
    sx, sy, sz,
  )

proc translate(node: horde3d.Node, vector: Vector) =
  ## Translates node relative to its direction
  # TODO: ugly
  var tx, ty, tz, rx, ry, rz, sx, sy, sz: cfloat
  node.getNodeTransform(
    tx.addr, ty.addr, tz.addr,
    rx.addr, ry.addr, rz.addr,
    sx.addr, sy.addr, sz.addr,
  )

  let vector = vector.rotate(rx, ry)

  node.setNodeTransform(
    tx + vector[0], ty + vector[1], tz + vector[2],
    rx, ry, rz,
    sx, sy, sz,
  )


# method process(self: ref ActionVideoSystem, message: ref SetPositionMessage) =
#   self.camera.translate(Vector(@[message.x, message.y, message.z]))
