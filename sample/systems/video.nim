import tables
import strformat
import logging

import c4.core.entities
import c4.systems.video
import c4.core.messages as c4_messages
import c4.defaults.states as default_states
import c4.defaults.messages as default_messages
import c4.wrappers.horde3d.horde3d

import "../core/messages"


var entityMap = initTable[Entity, Entity]()  # converter: remote Entity -> local Entity


method process(self: ref VideoSystem, message: ref AddEntityMessage) =
  var entity = newEntity()
  entityMap[message.entity] = entity

  logging.debug &"Created entity {entity}"
  entity[ref Video] = new(Video)
  entity[ref Video][].init()

method process(self: ref VideoSystem, message: ref PhysicsMessage) =
  var entity = entityMap[message.entity]
  logging.debug &"Moving entity {entity} to {message.physics.x} {message.physics.y} {message.physics.z}"
  entity[ref Video][].transform(
    translation=(message.physics.x, message.physics.y, message.physics.z)
  )

method process(self: ref VideoSystem, message: ref RotateMessage) =
  # TODO: ugly
  var tx, ty, tz, rx, ry, rz, sx, sy, sz: cfloat
  self.camera.GetNodeTransform(
    tx.addr, ty.addr, tz.addr,
    rx.addr, ry.addr, rz.addr,
    sx.addr, sy.addr, sz.addr,
  )

  self.camera.SetNodeTransform(
    tx, ty, tz,
    (rx - (message.pitch / 8).cfloat).max(-85).min(85),  # here we limit camera pitch
    ry - (message.yaw / 8).cfloat,
    0.cfloat,
    sx, sy, sz,
  )

method process(self: ref VideoSystem, message: ref MoveForwardMessage) =
  var tx, ty, tz, rx, ry, rz, sx, sy, sz: cfloat
  self.camera.GetNodeTransform(
    tx.addr, ty.addr, tz.addr,
    rx.addr, ry.addr, rz.addr,
    sx.addr, sy.addr, sz.addr,
  )  

  let (px, py, pz) = getProjection(rx, ry)

  self.camera.SetNodeTransform(
    tx + px, ty + py, tz + pz,
    rx, ry, rz,
    sx, sy, sz
  )

method process(self: ref VideoSystem, message: ref MoveBackwardMessage) =
  var tx, ty, tz, rx, ry, rz, sx, sy, sz: cfloat
  self.camera.GetNodeTransform(
    tx.addr, ty.addr, tz.addr,
    rx.addr, ry.addr, rz.addr,
    sx.addr, sy.addr, sz.addr,
  )

  let (px, py, pz) = getProjection(rx, ry)

  self.camera.SetNodeTransform(
    tx - px, ty - py, tz - pz,
    rx, ry, rz,
    sx, sy, sz
  )
