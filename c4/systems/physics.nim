from logging import debug
from "../systems" import System, init, update


type
  PhysicsSystem* = object of System
  Physics* = object {.inheritable.}
    x*, y*, z*: float


method init*(self: ref PhysicsSystem) =
  procCall ((ref System)self).init()

method update*(self: ref PhysicsSystem, dt: float) =
  procCall ((ref System)self).update(dt)

{.experimental.}
method `=destroy`*(self: ref PhysicsSystem) {.base.} =
  discard
