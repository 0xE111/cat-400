import c4/entities
import c4/messages
import c4/systems/network/net

import ./utils


type
  EntityMessage* = object of NetworkMessage
    entity*: Entity

  EntityCreateMessage* = object of EntityMessage

  EntityMoveMessage* = object of EntityMessage
    x*, y*, z*: float

  EntityRotateMessage* = object of EntityMessage
    quaternion*: Quaternion

  PlayerRotateMessage* = object of NetworkMessage
    yaw*, pitch*: float

  PlayerMoveMessage* = object of NetworkMessage
    yaw*: float

  ImpersonateMessage* = object of EntityMessage


register EntityMessage
register EntityCreateMessage
register EntityMoveMessage
register PlayerRotateMessage
register ImpersonateMessage
register EntityRotateMessage
register PlayerMoveMessage