import c4/entities
import c4/messages
import c4/systems/network/net


type
  EntityMessage* = object of NetworkMessage
    entity*: Entity

  EntityCreateMessage* = object of EntityMessage
    width*, height*: float

  EntityMoveMessage* = object of EntityMessage
    x*, y*: float


register EntityMessage
register EntityCreateMessage
register EntityMoveMessage
