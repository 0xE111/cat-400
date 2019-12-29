import c4/messages
import c4/systems/network/enet
import c4/systems/physics/simple


type EntityKind* = enum
  wall, gate, paddle, ball

type CreateTypedEntityMessage* = object of CreateEntityMessage
  kind*: EntityKind
register CreateTypedEntityMessage


type SetDimensionMessage* = object of EntityMessage
  ## Tells client size of object
  width*: float
  height*: float
register SetDimensionMessage

type SetPositionMessage* = object of EntityMessage
  ## Tells client where specific entity should be located
  x*: float
  y*: float
register SetPositionMessage

type MovementDirection* = enum
  left, right

type MoveMessage* = object of NetworkMessage
  ## Client sends to server when arrow is pressed
  direction*: MovementDirection
register MoveMessage
