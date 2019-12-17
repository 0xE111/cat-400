import c4/messages
import c4/systems/network/enet
import c4/systems/physics/simple



type SetPositionMessage* = object of EntityMessage
  ## Tells client where specific entity should be located
  x*: float
  y*: float

register SetPositionMessage
