import ../../core/messages
import ../../core/entities
import ../../utils/stringify


type PlayerMoveMessage* = object of Message
  ## Message for defining player's movement direction. The movement direction is relative to player's sight direction.
  yaw*: float  ## Angle (in radians) around Y axis.
  pitch*: float  ## Angle (in radians) around X axis.
messages.register(PlayerMoveMessage)


type PlayerRotateMessage* = object of Message
  ## Message for defining player's rotation. See ``MoveMessage`` for reference.
  yaw*: float  ## Angle (in radians) around Y axis.
  pitch*: float  ## Angle (in radians) around X axis.
messages.register(PlayerRotateMessage)


type SetPositionMessage* = object of EntityMessage
  ## Send this message to client in order to update object's position.
  x*, y*, z*: float
messages.register(SetPositionMessage)


type SetRotationMessage* = object of EntityMessage
  ## Send this message to client in order to update object's rotation.
  quaternion*: array[4, float]  # rotation quaternion
messages.register(SetRotationMessage)


type SyncPositionMessage* = object of SetPositionMessage
  ## Reliable version of SetPositionMessage
  discard
messages.register(SyncPositionMessage)

method isReliable*(self: ref SyncPositionMessage): bool {.inline.} =
  ## Send this message reliably
  true


type SyncRotationMessage* = object of SetRotationMessage
  ## Reliable version of SetRotationMessage
  discard
messages.register(SyncRotationMessage)

method isReliable*(self: ref SyncRotationMessage): bool {.inline.} =
  ## Send this message reliably
  true


type ImpersonationMessage* = object of EntityMessage
  ## A signal for client to occupy selected entity
  discard
messages.register(ImpersonationMessage)
