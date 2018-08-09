import tables
import strformat
import logging

import "../../../core/entities"
import "../../../systems"
import "../../../systems/video/horde3d" as video

import "../../../wrappers/horde3d/horde3d"
import "../../../wrappers/horde3d/horde3d/helpers"

import physics
import "../messages"


type
  ActionVideoSystem* = object of VideoSystem


method process(self: ref ActionVideoSystem, message: ref CreateEntityMessage) =
  let video = new(Video)
  self.initComponent(video)

  message.entity[ref Video] = video

method process(self: ref ActionVideoSystem, message: ref SetPositionMessage) =
  var video = message.entity[ref Video]
  let curTransform = video.node.getTransform()

  video.node.setNodeTransform(
    message.x, message.y, message.z,
    curTransform.rx, curTransform.ry, curTransform.rz,
    curTransform.sx, curTransform.sy, curTransform.sz,
  )

method process(self: ref ActionVideoSystem, message: ref PlayerRotateMessage) =
  let curTransform = self.camera.getTransform()

  self.camera.setNodeTransform(
    curTransform.tx, curTransform.ty, curTransform.tz,
    (curTransform.rx - (message.pitch / 8).cfloat).max(-85).min(85),  # here we limit camera pitch
    curTransform.ry - (message.yaw / 8).cfloat,
    curTransform.rz,
    curTransform.sx, curTransform.sy, curTransform.sz,
  )
