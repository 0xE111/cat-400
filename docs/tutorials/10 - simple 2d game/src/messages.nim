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

  MoveUpMessage* = object of NetworkMessage
  MoveDownMessage* = object of NetworkMessage


register EntityMessage
register EntityCreateMessage
register EntityMoveMessage
register MoveUpMessage
register MoveDownMessage
