import "../../core/messages"
import "../../core/entities"
import "../../utils/stringify"


type
  PlayerMoveMessage* = object of Message
    ## Message for defining player's movement direction.
    ## Yaw is angle (in radians) around Y axis.
    ## Pitch is angle around X axis.
    yaw*, pitch*: float

  PlayerRotateMessage* = object of Message
    ## Message for defining player's rotation. See ``MoveMessage`` for reference.
    yaw*, pitch*: float

  SetPositionMessage* = object of EntityMessage
    ## Send this message from server to client in order to update object's position.
    x*, y*, z*: float


messages.register(PlayerMoveMessage)
strMethod(PlayerMoveMessage)

messages.register(PlayerRotateMessage)
strMethod(PlayerRotateMessage)

messages.register(SetPositionMessage)
strMethod(SetPositionMessage)
