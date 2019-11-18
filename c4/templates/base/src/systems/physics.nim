import c4/systems/physics/ode

import ../messages


type PhysicsSystem* = object of ode.PhysicsSystem

proc run*(self: var PhysicsSystem) =
  ode.PhysicsSystem(self).run()

# redefine physics system methods below
