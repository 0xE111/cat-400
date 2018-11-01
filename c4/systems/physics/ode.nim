import logging
import strformat
import math
import tables

import ../../config
import ../../core/entities
import ../../systems
import ../../wrappers/ode/ode
import ../../utils/floats
import ../../utils/stringify


const simulationStep = 1 / 30

type
  PhysicsSystem* = object of System
    world*: dWorldID
    simulationStepRemains: float

  Physics* = object {.inheritable.}
    body*: dBodyID
    geometry*: dGeomID


# ---- Component ----
method init*(self: ref Physics) {.base.} =
  assert config.systems.physics of ref PhysicsSystem

  logging.debug &"Physics system: initializing component"

  self.body = config.systems.physics.as(ref PhysicsSystem).world.bodyCreate()
  self.body.bodySetPosition(0.0, 0.0, 0.0)

  # logging.debug &"Initializing mass"
  # var mass: = create(ode.dMass)
  # var mass: ode.dMass  # var mass: ptr ode.dMass = cast[ptr ode.dMass](alloc(sizeof(ode.dMass)))
  # mass.addr.massSetBoxTotal(1.0, 1.0, 1.0, 1.0)
  # component.body.bodySetMass(mass.addr)

method dispose*(self: ref Physics) {.base.} =
  logging.debug &"Physics system: destroying component"
  self.body.bodyDestroy()

method update*(self: ref Physics, dt: float, entity: Entity) {.base.} =
  discard


# ---- System ----
strMethod(PhysicsSystem, fields=false)

method init*(self: ref PhysicsSystem) =
  ode.initODE()
  self.world = ode.worldCreate()
  self.simulationStepRemains = 0
  logging.debug "ODE initialized"

  procCall self.as(ref System).init()

method update*(self: ref PhysicsSystem, dt: float) =
  let
    dt = dt + self.simulationStepRemains
    nSteps = (dt / simulationStep).int

  self.simulationStepRemains = dt.mod(simulationStep)

  for i in 0..<nSteps:
    if self.world.worldStep(simulationStep) == 0:
      raise newException(LibraryError, "Error while simulating world")

  for entity, physics in getComponents(ref Physics).pairs():
    physics.update(dt, entity)

  procCall self.as(ref System).update(dt)

proc `=destroy`*(self: var PhysicsSystem) =
  self.world.worldDestroy()
  ode.closeODE()
  logging.debug "ODE destroyed"
