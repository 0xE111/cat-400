import logging
import strformat
import math
import tables

import "../../config"
import "../../systems"
import "../../wrappers/ode/ode"
import "../../core/entities"
import "../../utils/floats"


const simulationStep = 1 / 30

type
  PhysicsSystem* = object of System
    world*: dWorldID
    simulationStepRemains: float

  Physics* = object of SystemComponent
    body*: dBodyID
    geometry*: dGeomID


method init*(self: ref PhysicsSystem) =
  ode.initODE()
  self.world = ode.worldCreate()
  self.simulationStepRemains = 0
  logging.debug "ODE initialized"

  procCall ((ref System)self).init()


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

  procCall ((ref System)self).update(dt)

proc `=destroy`*(self: var PhysicsSystem) =
  self.world.worldDestroy()
  ode.closeODE()
  logging.debug "ODE destroyed"


method initComponent*(self: ref PhysicsSystem, component: ref Physics) =
  logging.debug &"Physics system: initializing component"

  component.body = self.world.bodyCreate()
  component.body.bodySetPosition(0.0, 0.0, 0.0)
  
  # logging.debug &"Initializing mass"
  # var mass: = create(ode.dMass)
  # var mass: ode.dMass  # var mass: ptr ode.dMass = cast[ptr ode.dMass](alloc(sizeof(ode.dMass)))
  # mass.addr.massSetBoxTotal(1.0, 1.0, 1.0, 1.0)
  # component.body.bodySetMass(mass.addr)

method destroyComponent*(self: ref PhysicsSystem, component: ref Physics) =
  logging.debug &"Physics system: destroying component"
  component.body.bodyDestroy()

proc getPosition*(self: ref Physics): tuple[x, y, z: float] =
  let position = self.body.bodyGetPosition()[]
  result = (x: position[0], y: position[1], z: position[2])
