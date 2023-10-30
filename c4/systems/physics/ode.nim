import math
import system

import ../../logging
import ../../systems
import ../../messages
import ../../lib/ode/ode


const simulationStep = 1 / 30

type
  PhysicsSystem*  = object of System
    world*: dWorldID
    space*: dSpaceID
    nearCallback*: dNearCallback

    contactGroup: dJointGroupID
    simulationStepRemains: float

  Physics* = object of RootObj
    body*: dBodyID

  PhysicsInitMessage* = object of Message


proc nearCallback(data: pointer, geom1: dGeomID, geom2: dGeomID) =
  let
    self = cast[ptr PhysicsSystem](data)[]
    body1 = geom1.geomGetBody()
    body2 = geom2.geomGetBody()

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
  for i in 0..<numCollisions:
    let contact = jointCreateContact(self.world, self.contactGroup, contact[i].addr)
    contact.jointAttach(body1, body2)


method process*(self: ref PhysicsSystem, message: ref PhysicsInitMessage) =
  withLog(DEBUG, "initializing physics engine"):
    initODE()
    self.world = worldCreate()
    # self.world.worldSetAutoDisableFlag(1)
    self.space = hashSpaceCreate(nil)
    self.simulationStepRemains = 0
    self.nearCallback = nearCallback  # cast[ptr dNearCallback](nearCallback.rawProc)
    self.contactGroup = jointGroupCreate(0)


method update*(self: ref PhysicsSystem, dt: float) =
  let
    dt = dt + self.simulationStepRemains
    nSteps = (dt / simulationStep).int

  self.simulationStepRemains = dt.mod(simulationStep)

  for i in 0..<nSteps:
    self.space.spaceCollide(cast[pointer](self[].addr), cast[ptr dNearCallback](self.nearCallback.rawProc))
    if self.world.worldStep(simulationStep) == 0:
      raise newException(LibraryError, "Error while simulating world")
    self.contactGroup.jointGroupEmpty()


method dispose*(self: ref PhysicsSystem) =
  withLog(DEBUG, "disposing physics engine"):
    self.contactGroup.jointGroupDestroy()
    self.space.spaceDestroy()
    self.world.worldDestroy()
    ode.closeODE()


when isMainModule:
  import unittest

  suite "System tests":
    test "Running":
      let system = new(PhysicsSystem)
      system.process(new(PhysicsInitMessage))

      let body = system.world.bodyCreate()
      body.bodySetPosition(0.0, 0.0, 0.0)

      let entity = newEntity()
      entity[Physics] = Physics(body: body)

      system.run()
