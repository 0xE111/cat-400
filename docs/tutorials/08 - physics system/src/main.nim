import c4/threads
import c4/systems
import c4/systems/physics/ode
import c4/logging

import systems/physics


when isMainModule:
  spawnThread ThreadID(1):
    let system = new(physics.PhysicsSystem)
    system.process(new(PhysicsInitMessage))  # process immediately
    new(CreateEntityMessage).send(threadID)  # process in system loop
    system.run(frequency=30)

  joinActiveThreads()
