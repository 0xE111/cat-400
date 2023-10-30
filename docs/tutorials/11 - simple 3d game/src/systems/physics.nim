import math
import sequtils
import std/random

import delaunator

import c4/lib/ode/ode as libode
import c4/entities
import c4/systems/physics/ode
import c4/logging
import c4/sugar
import c4/threads

import ../messages
import ../threads

type
  PhysicsSystem* = object of ode.PhysicsSystem
    player*: Entity
    playerMovementElapsed*: float
    landscape*: Entity

  Physics* = object of ode.Physics
    # additionally store previous position & rotation;
    # position/rotation update messages are sent only when values really change
    prevPosition: dVector3  # TODO: replace with ODE's bodySetMovedCallback
    prevRotation: dQuaternion
    shape*: seq[dVector3]

proc createBoxBody(self: ref PhysicsSystem): dBodyID =
  result = self.world.bodyCreate()

  let geometry = createBox(self.space, 0.1, 0.1, 0.1)
  geometry.geomSetBody(result)

  # let mass = cast[ptr dMass](alloc(sizeof(dMass)))
  # # TODO: var mass = ode.dMass()
  # mass.massSetBoxTotal(0.5, 1.0, 1.0, 1.0)
  # result.bodySetMass(mass)


proc `-`(vec1: dVector3, vec2: dVector3): dVector3 =
  for i in 0..2:
    result[i] = vec1[i] - vec2[i]

proc `*`(vec: dVector3, scalar: dReal): dVector3 =
  for i in 0..2:
    result[i] = vec[i] * scalar


proc `$`(body: dBodyID): string =
  body.repr()


proc nearCallback(data: pointer, geom1: dGeomID, geom2: dGeomID) =

  let
    body1 = geom1.geomGetBody()
    body2 = geom2.geomGetBody()

  # debug "near callback", body1, body2

  if body1 == nil or body2 == nil:
    return

  var kinematicBody: dBodyID
  var dynamicBody: dBodyID

  if body1.bodyIsKinematic().bool and not body2.bodyIsKinematic().bool:
    kinematicBody = body1
    dynamicBody = body2
  elif body2.bodyIsKinematic().bool and not body1.bodyIsKinematic().bool:
    kinematicBody = body2
    dynamicBody = body1
  else:
    # warn "unsupported collision type"
    return

  debug "near callback", body1, body2
  let dynamicPosition = dynamicBody.bodyGetPosition()[]
  let kinematicPosition = kinematicBody.bodyGetPosition()[]
  let velocity = dynamicBody.bodyGetLinearVel()[]

  const maxContacts = 4
  var contact {.global.}: array[maxContacts, dContact]
  for i in 0..<maxContacts:
    contact[i] = dContact()
    contact[i].surface.mode = dContactBounce or dContactSoftCFM
    contact[i].surface.mu = dInfinity
    contact[i].surface.mu2 = 0
    contact[i].surface.bounce = 0.00
    contact[i].surface.bounce_vel = 0.0
    contact[i].surface.soft_cfm = 0.00

  let numCollisions = collide(geom1, geom2, maxContacts.cint, contact[0].geom.addr, sizeof(dContact).cint)
  if numCollisions == 0:
    return
  # for i in 0..<numCollisions:
  #   let contact = jointCreateContact(self.world, self.contactGroup, contact[i].addr)
  #   contact.jointAttach(body1, body2)

  # echo "KINEMATIC POS: " & $kinematicPosition
  # echo "DYNAMIC POS: " & $dynamicPosition

  let forbiddenDirection = kinematicPosition - dynamicPosition
  let newVelocity = forbiddenDirection * -0.1
  # dynamicBody.bodySetLinearVel(newVelocity[0], newVelocity[1], newVelocity[2])
  dynamicBody.bodySetLinearVel(0.0, 0.0, 0.0)
  debug "trimmed velocity due to collision", velocity, forbiddenDirection  # , newVelocity


proc createLandscape(self: ref PhysicsSystem): Entity =
  result = newEntity()

  let body = self.world.bodyCreate()
  body.bodySetKinematic()
  body.bodySetPosition(0.0, 0.0, 0.0)

  let physics = (ref Physics)(body: body)
  # var points: seq[array[2, float]]
  # for i in 0..<10:
  #   points.add([rand(-10..10).float, rand(-10..10).float])
  # var points = @[[0.0, 5.0], [3.0, -3.0], [-3.0, -3.0]]  # , [40, 61]]

  var points = @[[-1.0, 1.0], [2.0, 4.0], [5.0, 1.0]]
  let delaunay = delaunator.fromPoints[array[2, float], float](points)
  for index in @[0, 1, 2]:  # delaunay.triangles:
    let point = points[index]
    physics.shape.add([point[0].dReal, index.dReal, point[1].dReal])
  assert physics.shape.len > 0, "delaunay failed to triangulate points"

  result[ref Physics] = physics

  var
    numPoints = physics.shape.len
    rawValues = alloc0(sizeof(dReal) * numPoints * 4)  # https://github.com/nim-lang/Nim/issues/11180#issuecomment-489430610
    values = cast[ptr UncheckedArray[dReal]](rawValues)
    rawIndexes = alloc0(sizeof(dTriIndex) * numPoints)
    indexes = cast[ptr UncheckedArray[dTriIndex]](rawIndexes)

  for i in 0..<numPoints:
    let point = physics.shape[i]
    values[i*4+0] = point[0]
    values[i*4+1] = point[1]
    values[i*4+2] = point[2]
    values[i*4+3] = 0.dReal
    indexes[i] = i.dTriIndex

  let triMeshData = dGeomTriMeshDataCreate()
  for i in 0..<numPoints:
    echo $indexes[i] & ": " & $values[i*4+0] & " " & $values[i*4+1] & " " & $values[i*4+2] & " " & $values[i*4+3]

  triMeshData.dGeomTriMeshDataBuildSimple(cast[ptr dReal](rawValues), numPoints, cast[ptr dTriIndex](rawIndexes), numPoints)
  # dealloc(rawValues)
  # dealloc(rawIndexes)

  let geom = dCreateTriMesh(self.space, triMeshData, nil, nil, nil)
  geom.geomSetBody(physics.body)


method process*(self: ref PhysicsSystem, message: ref PhysicsInitMessage) =
  procCall self.as(ref ode.PhysicsSystem).process(message)
  self.nearCallback = nearCallback

  let body = self.createBoxBody()
  body.bodySetPosition(0.0, 3.0, 10.0)
  self.player = newEntity()
  self.player[ref Physics] = (ref Physics)(body: body)

  let
    xMin = -2.dReal
    xMax = 6.dReal
    zMin = -2.dReal
    zMax = 6.dReal
    step = 1.dReal

  for i in 0..int((xMax - xMin) / step):
    for j in 0..int((zMax - zMin) / step):
      let body = self.createBoxBody()
      body.bodySetPosition(xMin + i.dReal*step, 4.0.dReal, zMin + j.dReal*step)
      # body.bodySetKinematic()
      let entity = newEntity()
      entity[ref Physics] = (ref Physics)(body: body)
      body.bodySetLinearVel(0.0, -2.0, 0.0)

  self.landscape = self.createLandscape()


method update*(self: ref PhysicsSystem, dt: float) {.gcsafe.} =

  procCall self.as(ref ode.PhysicsSystem).update(dt)

  for entity, physics in getComponents(ref Physics):
    ## compare previous position and rotation of entity, and if there are any changes -
    ## send entity move/rotate message
    let position = physics.body.bodyGetPosition()[]
    for dimension in 0..2:
      if position[dimension] != physics.prevPosition[dimension]:
        physics.prevPosition = position
        (ref EntityMoveMessage)(
          entity: entity,
          x: position[0],
          y: position[1],
          z: position[2],
        ).send(networkThread)
        break

    if position[1] < -3.0:
      physics.body.bodySetLinearVel(0.0, 0.0, 0.0)

    let rotation = physics.body.bodyGetQuaternion()[]
    for dimension in 0..3:
      if rotation[dimension] != physics.prevRotation[dimension]:
        physics.prevRotation = rotation
        (ref EntityRotateMessage)(
          entity: entity,
          quaternion: rotation,
        ).send(networkThread)
        break

  if self.playerMovementElapsed > 0:
    self.playerMovementElapsed -= dt
    if self.playerMovementElapsed <= 0:
      # it's time to stop movement
      self.player[ref physics.Physics].body.bodySetLinearVel(0, 0, 0)
