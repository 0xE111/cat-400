import c4/entities
import c4/messages
import c4/systems/network/net


type
  EntityMessage* = object of NetworkMessage
    entity*: Entity

  EntityCreateMessage* = object of EntityMessage

  EntityMoveMessage* = object of EntityMessage
    x*, y*, z*: float

  PlayerRotateMessage* = object of NetworkMessage
    yaw*, pitch*: float


register EntityMessage
register EntityCreateMessage
register EntityMoveMessage
register PlayerRotateMessage
