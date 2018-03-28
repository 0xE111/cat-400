{.deprecated.}

import entities
import "../wrappers/msgpack/msgpack"

from "../systems/physics" import Physics
from streams import Stream, atEnd
from messages import Message, EntityMessage, broadcast


type
  Scene* = object
    ## Scene is a set of entities which can be saved and restored
    entities: set[Entity]


proc add*(self: var Scene, entity: Entity) =
  self.entities.incl(entity)

proc del*(self: var Scene, entity: Entity) =
  self.entities.excl(entity)

iterator entities*(self: Scene): Entity =
  for entity in self.entities:
    yield entity

# ---- serialization ----
# proc pack_type*(stream: Stream, scene: Scene) =
#   for entity in scene.entities:
#     stream.pack(entity)
#     if entity.has(Physics):
#       stream.pack(true)
#       stream.pack(entity[Physics])
#     else:
#       stream.pack(false)

# proc unpack_type*(stream: Stream, scene: var Scene) =
#   var
#     entity: Entity
#     hasPhysics: bool

#   while not stream.atEnd:
#     stream.unpack(entity)
#     stream.unpack(hasPhysics)
#     if hasPhysics:
#       stream.unpack(entity[Physics])


type
  AddEntityMessage* = object of EntityMessage
  DelEntityMessage* = object of EntityMessage

register(Message, AddEntityMessage)
register(Message, DelEntityMessage)

proc load*(self: var Scene) =
  let player = newEntity()  # create new entity
  self.add(player)  # add entity to scene
  (ref AddEntityMessage)(entity: player).broadcast()  # send message

  player[ref Physics] = (ref Physics)(x: 0, y: 0, z: 0)  # init physics for player
  player[ref Physics].x = 1  # update player physics

  let cube = newEntity()
  self.add(cube)
  (ref AddEntityMessage)(entity: cube).broadcast()

  cube[ref Physics] = (ref Physics)(x: 0, y: 0, z: -5)
