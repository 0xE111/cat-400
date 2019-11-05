import c4/systems/physics/ode
import c4/utils/stringify

import ../messages


type
  PhysicsSystem* = object of ode.PhysicsSystem


strMethod(PhysicsSystem, fields=false)

# redefine physics system methods below
