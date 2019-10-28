import logging
import strformat
import math
import tables
import system

import ../../entities
import ../../systems
import ../../utils/stringify

import ../../lib/ode/ode


const simulationStep = 1 / 30

type
  PhysicsSystem* = object of System
    world*: dWorldID
    space*: dSpaceID
    nearCallback*: dNearCallback
    # contactGroup: dJointGroupID
    simulationStepRemains: float

  Physics* {.inheritable.} = object
    body*: dBodyID


# ---- Component ----

method init*(self: ref PhysicsSystem, physics: ref Physics) {.base.} =
  logging.debug &"{self}: initializing component"
  physics.body = self.world.bodyCreate()
  physics.body.bodySetPosition(0.0, 0.0, 0.0)

method attach*(self: ref Physics) {.base.} =
  discard

method detach*(self: ref Physics) {.base.} =
  logging.debug &"Physics system: destroying component"
  self.body.bodyDestroy()

method update*(self: ref Physics, dt: float, entity: Entity) {.base.} =
  discard


# ---- System ----
strMethod(PhysicsSystem, fields=false)

proc nearCallback(data: pointer, o1: dGeomID, o2: dGeomID) =
  echo "Possible collision!"
  # static const int N = 4; // As for the upper limit of contact score without forgetting 4 static, attaching - chego blyat?!

  # dContact contact [ N ];

  # int isGround = ((ground == o1) || (ground == o2));
  # int n = dCollide (o1, o2, N and &contact [ 0 ] geom, sizeof (dContact)); // As for n collision score
  # if (isGround) { //the flag of the ground stands, collision detection function can be used
  # for (int i = 0; I < n; I++) {
  # contact [ i ] surface.mode = dContactBounce; // Setting the coefficient of rebound of the land
  # contact [ i ] surface.bounce = 0.0; // (0.0 – 1.0) as for coefficient of rebound from 0 up to 1
  # contact [ i ] surface.bounce_vel = 0.0; // (0.0 or more) the lowest speed which is necessary for rally

  # / / Contact joint formation
  # dJointID c = dJointCreateContact (world, contactgroup and &contact [ i ]);
  # // Restraining two geometry which contact with the contact joint
  # dJointAttach (c, dGeomGetBody (contact [ i ] geom.g1),
  # dGeomGetBody (contact [ i ] geom.g2));
  # }
  # }
  # }


method init*(self: ref PhysicsSystem) =
  ode.initODE()
  self.world = worldCreate()
  # self.world.worldSetAutoDisableFlag(1)
  self.space = hashSpaceCreate(nil)
  self.simulationStepRemains = 0
  self.nearCallback = nearCallback  # cast[ptr dNearCallback](nearCallback.rawProc)
  # self.contactGroup = jointGroupCreate(0);
  logging.debug "ODE initialized"

  procCall self.as(ref System).init()


method update*(self: ref PhysicsSystem, dt: float) =
  let
    dt = dt + self.simulationStepRemains
    nSteps = (dt / simulationStep).int

  self.simulationStepRemains = dt.mod(simulationStep)

  for i in 0..<nSteps:
    self.space.spaceCollide(nil, cast[ptr dNearCallback](self.nearCallback.rawProc))
    if self.world.worldStep(simulationStep) == 0:
      raise newException(LibraryError, "Error while simulating world")

  for entity, physics in getComponents(ref Physics).pairs():
    physics.update(dt, entity)

  procCall self.as(ref System).update(dt)

proc `=destroy`*(self: var PhysicsSystem) =
  self.world.worldDestroy()
  ode.closeODE()
  logging.debug "ODE destroyed"
