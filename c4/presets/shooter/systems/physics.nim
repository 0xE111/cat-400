import "../../../systems/physics"

  
type
  ShooterPhysics* = object of Physics
    health*: uint8
