import "../../../systems/physics/ode"

  
type
  ShooterPhysics* = object of Physics
    health*: uint8
