import tables
import strformat
import logging
import typetraits

import ../../../core/entities
import ../../../systems
import ../../../systems/video/horde3d as video

import ../../../wrappers/horde3d/horde3d
import ../../../wrappers/horde3d/horde3d/helpers

import physics
import ../messages


type
  ActionVideoSystem* = object of VideoSystem


# method process(self: ref ActionVideoSystem, message: ref CreateEntityMessage) =
#   message.entity[ref Video] = Video.new()

method process(self: ref ActionVideoSystem, message: ref SetPositionMessage) =
  if not message.entity.has(ref Video):
    logging.warn &"{self[].type.name} received {message}, but has no Video component"
    # raise newException(LibraryError, "Shit im getting errors")
    # TODO: When client just connected to server, the server still may broadcast some messages
    # before syncing world state with client. When these messages reach client, it doesn't have
    # corresponding components yet, thus won't be able to process these messages and fail.
    return

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
