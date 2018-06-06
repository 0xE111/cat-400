import tables
import strformat
import logging

import "../../../core/entities"
import "../../../systems/video/horde3d" as video
import "../../../core/messages"

import "../../../wrappers/horde3d/horde3d"

import physics
import "../utils/matrix"


type
  ActionVideoSystem* = object of VideoSystem

  CubeVideo* = object of Video

var
  cubeResource: horde3d.Res  # TODO: move to CustomVideoSystem
  skyboxResource: horde3d.Res


# DEMO
# var skyboxRes: horde3d.Res

method init*(self: ref ActionVideoSystem) =
  procCall ((ref VideoSystem)self).init()

  # load custom resources
  cubeResource = addResource(ResTypes.SceneGraph, "models/cube/cube.scene.xml")
  skyboxResource = addResource(ResTypes.SceneGraph, "models/skybox/skybox.scene.xml")
  if cubeResource == 0 or skyboxResource == 0:
    let msg = "Custom resources not loaded"
    logging.fatal msg
    raise newException(LibraryError, msg)

  self.loadResources()

  var sky = RootNode.addNodes(skyboxResource)
  sky.setNodeTransform(0, 0, 0, 0, 0, 0, 210, 50, 210)
  sky.setNodeFlags(NodeFlags.NoCastShadow, true)

method process(self: ref ActionVideoSystem, message: ref CreateEntityMessage) =
  message.entity[ref Video] = new(CubeVideo)
  message.entity[ref Video][].init()

# method process(self: ref ActionVideoSystem, message: ref ActionPhysicsMessage) =
#   logging.debug &"Moving entity {message.entity} to {message.x} {message.y} {message.z}"
#   message.entity[ref Video][].transform(
#     translation=(message.x.float, message.y.float, message.z.float)
#   )

method process(self: ref ActionVideoSystem, message: ref RotateMessage) =
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


method process(self: ref ActionVideoSystem, message: ref MoveMessage) =
  self.camera.translate(Vector(@[message.x, message.y, message.z]))


# ---- component ----
method init(self: var CubeVideo) =
  self.node = RootNode.addNodes(cubeResource)
