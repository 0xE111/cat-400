import logging
import strformat
import math
import system
import unittest
import os
import typetraits

import ../../lib/ode/ode

import ../../threads
import ../../messages
import ../../entities
import ../../loop


const simulationStep = 1 / 30

type
  OdePhysicsSystem* {.inheritable.} = object
    world*: dWorldID
    space*: dSpaceID
    nearCallback*: dNearCallback
    contactGroup: dJointGroupID
    simulationStepRemains: float

  OdePhysics* {.inheritable.} = object
    body*: dBodyID


# ---- Component ----

method init*(self: ref OdePhysicsSystem, physics: ref OdePhysics) {.base.} =
  logging.debug &"{self.type.name}: initializing component"
  physics.body = self.world.bodyCreate()
  physics.body.bodySetPosition(0.0, 0.0, 0.0)

method dispose*(self: ref OdePhysics) {.base.} =
  logging.debug &"{self.type.name}: destroying component"
  self.body.bodyDestroy()


# ---- System ----
proc nearCallback(data: pointer, geom1: dGeomID, geom2: dGeomID) =
  let
    self = cast[ptr OdePhysicsSystem](data)[]
    body1 = geom1.geomGetBody()
    body2 = geom2.geomGetBody()

  const maxContacts = 4

  var contact {.global.}: array[maxContacts, dContact]

  for i in 0..<maxContacts:
    contact[i] = dContact()
    contact[i].surface.mode = dContactBounce or dContactSoftCFM
    contact[i].surface.mu = dInfinity
    contact[i].surface.mu2 = 0
    contact[i].surface.bounce = 0.01
    contact[i].surface.bounce_vel = 0.1
    contact[i].surface.soft_cfm = 0.01

  let numCollisions = collide(geom1, geom2, maxContacts.cint, contact[0].geom.addr, sizeof(dContact).cint)
  for i in 0..<numCollisions:
    let contact = jointCreateContact(self.world, self.contactGroup, contact[i].addr)
    contact.jointAttach(body1, body2)


method init*(self: ref OdePhysicsSystem) {.base.} =
  ode.initODE()
  self.world = worldCreate()
  # self.world.worldSetAutoDisableFlag(1)
  self.space = hashSpaceCreate(nil)
  self.simulationStepRemains = 0
  self.nearCallback = nearCallback  # cast[ptr dNearCallback](nearCallback.rawProc)
  self.contactGroup = jointGroupCreate(0)

  logging.debug "ODE initialized"


method update*(self: ref OdePhysicsSystem, dt: float) {.base.} =
  let
    dt = dt + self.simulationStepRemains
    nSteps = (dt / simulationStep).int

  self.simulationStepRemains = dt.mod(simulationStep)

  for i in 0..<nSteps:
    self.space.spaceCollide(cast[pointer](self[].addr), cast[ptr dNearCallback](self.nearCallback.rawProc))
    if self.world.worldStep(simulationStep) == 0:
      raise newException(LibraryError, "Error while simulating world")
    self.contactGroup.jointGroupEmpty()


method dispose*(self: ref OdePhysicsSystem) {.base.} =
  self.contactGroup.jointGroupDestroy()
  self.space.spaceDestroy()
  self.world.worldDestroy()
  ode.closeODE()
  logging.debug "ODE destroyed"


method process*(self: ref OdePhysicsSystem, message: ref Message) {.base.} =
  logging.warn &"No rule for processing {message}"


method run*(self: ref OdePhysicsSystem) {.base.} =
  loop(frequency=30) do:
    self.update(dt)
    while true:
      let message = tryRecv()
      if message.isNil:
        break
      self.process(message)


when isMainModule:
  suite "System tests":
    test "Running inside thread":
      spawn("thread") do:
        var system = OdePhysicsSystem()
        system.init()
        system.run()
        system.dispose()

      sleep 1000
