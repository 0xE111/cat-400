import c4/messages
import c4/entities


type
  EntityMessage* = object of Message
    entity*: Entity

  CreatePlayerEntityMessage* = object of EntityMessage
  CreateBoxEntityMessage* = object of EntityMessage
  CreatePlaneEntityMessage* = object of EntityMessage

register CreatePlayerEntityMessage
register CreateBoxEntityMessage
register CreatePlaneEntityMessage


type PlayerMoveMessage* = object of Message
  # message for defining player's movement direction; the movement direction is relative to player's sight direction.
  yaw*: float  ## Angle (in radians) around Y axis.
  pitch*: float  ## Angle (in radians) around X axis.
register PlayerMoveMessage


type PlayerRotateMessage* = object of Message
  ## Message for defining player's rotation. See ``MoveMessage`` for reference.
  yaw*: float  ## Angle (in radians) around Y axis.
  pitch*: float  ## Angle (in radians) around X axis.
register PlayerRotateMessage


type SetPositionMessage* = object of EntityMessage
  ## Send this message to client in order to update object's position.
  x*, y*, z*: float
register SetPositionMessage


type
  Quaternion* = array[4, float]  # w, x, y, z
  SetRotationMessage* = object of EntityMessage
    ## Send this message to client in order to update object's rotation.
    quaternion*: Quaternion  # rotation quaternion
register SetRotationMessage


type SyncPositionMessage* = object of SetPositionMessage
  ## Reliable version of SetPositionMessage
  discard
register SyncPositionMessage


type SyncRotationMessage* = object of SetRotationMessage
  ## Reliable version of SetRotationMessage
  discard
register SyncRotationMessage


type ImpersonationMessage* = object of EntityMessage
  ## A signal for client to occupy selected entity
  discard
register ImpersonationMessage


type ResetSceneMessage* = object of Message  # This message will reset physics system to initial state, so that we can play again

# Always ``register`` Message subtypes. If not registered, network system won't have a knowledge on how to serialize the message, which will lead to sending pure ``Message`` instead of your subtype.
register ResetSceneMessage
