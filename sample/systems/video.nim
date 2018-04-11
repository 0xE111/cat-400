import tables

import c4.core.entities
import c4.systems.video
import c4.core.messages as c4_messages
import c4.defaults.states as default_states
import c4.defaults.messages as default_messages


var entityMap = initTable[Entity, Entity]()  # converter: remote Entity -> local Entity


method process(self: ref VideoSystem, message: ref AddEntityMessage) =
  echo "<<< AddEntity >>>"
  var entity = newEntity()
  entityMap[message.entity] = entity

  entity[ref Video] = new(Video)
  entity[ref Video][].init()

method process(self: ref VideoSystem, message: ref PhysicsMessage) =
  echo "<<< Physics >>>"
  var entity = entityMap[message.entity]
  entity[ref Video][].transform(
    translation=(message.physics.x, message.physics.y, message.physics.z)
  )
