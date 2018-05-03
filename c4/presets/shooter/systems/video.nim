import tables
import strformat
import logging

import "../../../core/entities"
import "../../../systems/video"
import "../../../core/messages"

import "../../default/states" as default_states
import "../../default/messages" as default_messages

import "../../../wrappers/horde3d/horde3d"

import "../messages" as shooter_messages
import "../utils/matrix"


type
  ShooterVideoSystem* = object of VideoSystem

  CubeVideo* = object of Video

var
  cubeResource: horde3d.Res  # TODO: move to CustomVideoSystem
  skyboxResource: horde3d.Res


var entityMap = initTable[Entity, Entity]()  # converter: remote Entity -> local Entity

# DEMO
# var skyboxRes: horde3d.Res

method init*(self: ref ShooterVideoSystem) =
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

method process(self: ref ShooterVideoSystem, message: ref AddEntityMessage) =
  var entity = newEntity()
  entityMap[message.entity] = entity

  logging.debug &"Created entity {entity}"
  entity[ref Video] = new(CubeVideo)
  entity[ref Video][].init()

method process(self: ref ShooterVideoSystem, message: ref PhysicsMessage) =
  var entity = entityMap[message.entity]
  logging.debug &"Moving entity {entity} to {message.physics.x} {message.physics.y} {message.physics.z}"
  entity[ref Video][].transform(
    translation=(message.physics.x, message.physics.y, message.physics.z)
  )

method process(self: ref ShooterVideoSystem, message: ref RotateMessage) =
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


method process(self: ref ShooterVideoSystem, message: ref MoveForwardMessage) =
  self.camera.translate(Vector(@[0.0, 0.0, -1.0]))

method process(self: ref ShooterVideoSystem, message: ref MoveBackwardMessage) =
  self.camera.translate(Vector(@[0.0, 0.0, 1.0]))

method process(self: ref ShooterVideoSystem, message: ref MoveLeftMessage) =
  self.camera.translate(Vector(@[-1.0, 0.0, 0.0]))

method process(self: ref ShooterVideoSystem, message: ref MoveRightMessage) =
  self.camera.translate(Vector(@[1.0, 0.0, 0.0]))

# ---- component ----
method init(self: var CubeVideo) =
  self.node = RootNode.addNodes(cubeResource)
