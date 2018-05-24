import logging
import strformat
import "../config"
import "../systems"
import "../wrappers/ode/ode"
import "../core/entities"


type
  PhysicsSystem* = object of System
    world*: dWorldID
    
  Physics* = object of SystemComponent
    body*: dBodyID


method init*(self: ref PhysicsSystem) =
  ode.initODE()
  self.world = ode.worldCreate()
  logging.debug "ODE initialized"

  # DEMO
  self.world.worldSetGravity(0, 0, -0.001)

  procCall ((ref System)self).init()

method update*(self: ref PhysicsSystem, dt: float) =
  procCall ((ref System)self).update(dt)

{.experimental.}
method `=destroy`*(self: ref PhysicsSystem) {.base.} =
  self.world.worldDestroy()
  ode.closeODE()
  logging.debug "ODE destroyed"


method initComponent*(self: ref PhysicsSystem, component: ref Physics) =
  logging.debug &"Initializing component for {self[]} system"
  # var mass: ptr ode.dMass = cast[ptr ode.dMass](alloc(sizeof(ode.dMass)))  # TODO: is this okay?
  var mass = ode.dMass()

  logging.debug &"Initializing mass"
  # mass.addr.massSetZero()
  echo $mass.mass
  # mass.massSetSphereTotal(1.0, 0.2)

  logging.debug &"Creating body"
  component.body = self.world.bodyCreate()
  # component.body.bodySetMass(mass)
  component.body.bodySetPosition(0.0, 0.0, 0.0)
