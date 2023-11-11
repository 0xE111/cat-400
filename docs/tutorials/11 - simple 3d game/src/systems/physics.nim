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

  Shape* = tuple[
    vertices: seq[dVector3],
    indexes: seq[array[3, int]],

    # TODO: this info is duplicated
    rawVertices: ptr UncheckedArray[dReal],
    rawIndexes: ptr UncheckedArray[dTriIndex],
  ]

  Physics* = object of ode.Physics
    # additionally store previous position & rotation;
    # position/rotation update messages are sent only when values really change
    prevPosition: dVector3  # TODO: replace with ODE's bodySetMovedCallback
    prevRotation: dQuaternion
    shape*: Shape


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

proc `*`(scalar: dReal, vec: dVector3): dVector3 =
  vec * scalar

proc `*`(vec1: dVector3, vec2: dVector3): dReal =
  vec1[0] * vec2[0] + vec1[1] * vec2[1] + vec1[2] * vec2[2]

proc project(vec: dVector3, onto: dVector3): dVector3 =
  onto * ((vec * onto) / (onto * onto))

proc `$`(body: dBodyID): string =
  body.repr()

proc getAngle(vec1: dVector3, vec2: dVector3): float =
  arccos(vec1 * vec2 / ((vec1*vec1) * (vec2*vec2)))


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
    warn "unsupported collision type", body1IsKinematic=body1.bodyIsKinematic().bool, body2IsKinematic=body2.bodyIsKinematic().bool
    return

  debug "near callback", body1, body2

  const maxContacts = 1
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

  assert maxContacts == 1
  let contactNormal = contact[0].geom.normal
  let velocity = dynamicBody.bodyGetLinearVel()[]
  if velocity[0] == 0.0 and velocity[1] == 0.0 and velocity[2] == 0.0:
    return

  let angle = getAngle(contactNormal, velocity)
  if angle <= 0.5 * PI:  # moving away from collision surface
    return

  let forbiddenDirection = velocity.project(contactNormal)
  let newVelocity = velocity - forbiddenDirection
  dynamicBody.bodySetLinearVel(newVelocity[0], newVelocity[1], newVelocity[2])

proc createLandscape(self: ref PhysicsSystem): Entity =
  result = newEntity()

  let body = self.world.bodyCreate()
  body.bodySetKinematic()
  body.bodySetPosition(0.0, 0.0, 0.0)

  let physics = (ref Physics)(body: body)
  result[ref Physics] = physics

  # ---- create a 2d grid of points ----
  var points: seq[array[2, float]]
  for i in 0..<100:
    points.add([rand(-10..10).float, rand(-10..10).float])

  # ---- triangulate the points ----
  let delaunay = delaunator.fromPoints[array[2, float], float](points)
  # ---- populate the physics shape (vertixes and indexes) ----
  for point in points:
    physics.shape.vertices.add([point[0].dReal, rand(0..1).dReal, point[1].dReal, 0.dReal])

  let numTriangles = int(delaunay.triangles.len / 3)
  assert numTriangles > 0, "failed to triangulate points"
  for triangleIndexes in delaunay.triangles.distribute(numTriangles):
    physics.shape.indexes.add(
      [triangleIndexes[0].int, triangleIndexes[1].int, triangleIndexes[2].int]
    )

  # ---- populate raw vertices for ODE ----
  let numVertices = physics.shape.vertices.len
  let rawVerticesPtr = alloc0(sizeof(dReal) * numVertices * 4)  # https://github.com/nim-lang/Nim/issues/11180#issuecomment-489430610
  physics.shape.rawVertices = cast[ptr UncheckedArray[dReal]](rawVerticesPtr)
  for i, vertex in physics.shape.vertices:
    physics.shape.rawVertices[i*4+0] = vertex[0]
    physics.shape.rawVertices[i*4+1] = vertex[1]
    physics.shape.rawVertices[i*4+2] = vertex[2]
    physics.shape.rawVertices[i*4+3] = vertex[3]

  # ---- populta raw indexes for ODE ----
  let rawIndexesPtr = alloc0(sizeof(dTriIndex) * numTriangles * 3)
  physics.shape.rawIndexes = cast[ptr UncheckedArray[dTriIndex]](rawIndexesPtr)
  for i, triangleIndexes in physics.shape.indexes:
    physics.shape.rawIndexes[i*3+0] = triangleIndexes[0].dTriIndex
    physics.shape.rawIndexes[i*3+1] = triangleIndexes[1].dTriIndex
    physics.shape.rawIndexes[i*3+2] = triangleIndexes[2].dTriIndex

  let triMeshData = dGeomTriMeshDataCreate()
  triMeshData.dGeomTriMeshDataBuildSimple(
    cast[ptr dReal](physics.shape.rawVertices), numVertices,
    cast[ptr dTriIndex](physics.shape.rawIndexes), numTriangles * 3,
  )
  # dealloc(rawValues)
  # dealloc(rawIndexes)

  let geom = dCreateTriMesh(self.space, triMeshData, nil, nil, nil)
  geom.geomSetBody(physics.body)


method process*(self: ref PhysicsSystem, message: ref PhysicsInitMessage) =
  procCall self.as(ref ode.PhysicsSystem).process(message)
  # self.world.worldSetGravity(0.0, -9.81, 0.0)
  self.nearCallback = nearCallback

  let body = self.createBoxBody()
  body.bodySetPosition(0.0, 3.0, 0.0)
  self.player = newEntity()
  self.player[ref Physics] = (ref Physics)(body: body)
  # body.bodySetGravityMode(1.cint)

  # let
  #   xMin = -2.dReal
  #   xMax = 6.dReal
  #   zMin = -2.dReal
  #   zMax = 6.dReal
  #   step = 1.dReal

  # for i in 0..int((xMax - xMin) / step):
  #   for j in 0..int((zMax - zMin) / step):
  #     let body = self.createBoxBody()
  #     body.bodySetPosition(xMin + i.dReal*step, 4.0.dReal, zMin + j.dReal*step)
  #     # body.bodySetKinematic()
  #     let entity = newEntity()
  #     entity[ref Physics] = (ref Physics)(body: body)
  #     body.bodySetLinearVel(0.0, -2.0, 0.0)

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
