from c4.systems.physics import Physics


type
  CustomPhysics* = object of Physics
    health*: uint8
