import strformat
import typetraits

import "../../core/messages"
import "../../core/entities"


type
  MoveMessage* = object of EntityMessage
    ## Message for defining player's movement direction.
    ## Yaw is angle (in radians) around Y axis.
    ## Pitch is angle around X axis.
    yaw*, pitch*: float

  RotateMessage* = object of EntityMessage
    ## Message for defining player's rotation. See ``MoveMessage`` for reference.
    yaw*, pitch*: float


messages.register(MoveMessage)
method `$`*(self: ref MoveMessage): string = &"{self[].type.name}: {self[]}"

messages.register(RotateMessage)
method `$`*(self: ref RotateMessage): string = &"{self[].type.name}: {self[]}"
