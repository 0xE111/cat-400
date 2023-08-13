import c4/systems/physics/ode
import c4/messages
import c4/entities
import c4/lib/ode/ode as libode
import c4/logging
import c4/sugar


type
  PhysicsSystem* = object of ode.PhysicsSystem
    entity: Entity
  CreateEntityMessage* = object of Message

method process*(self: ref PhysicsSystem, message: ref PhysicsInitMessage) =
  procCall self.as(ref ode.PhysicsSystem).process(message)
  self.world.worldSetGravity(0, -9.81, 0)

method process*(self: ref PhysicsSystem, message: ref CreateEntityMessage) =
  withLog(DEBUG, "creating new entity"):
    self.entity = newEntity()

    let body = self.world.bodyCreate()
    body.bodySetPosition(0.0, 0.0, 0.0)

    self.entity[Physics] = Physics(body: body)

method update*(self: ref PhysicsSystem, dt: float) =
  procCall self.as(ref ode.PhysicsSystem).update(dt)

  if self.entity.isInitialized():
    let position = self.entity[Physics].body.bodyGetPosition()[]
    info "tracking body position", entity=self.entity, position
