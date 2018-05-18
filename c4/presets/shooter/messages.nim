import "../../core/messages"
import "../../wrappers/enet/enet"
import "../../wrappers/msgpack/msgpack"
import "../../systems/physics"
import typetraits


type
  ConnectMessage* = object of Message
  LoadSceneMessage* = object of Message
  
  AddEntityMessage* = object of EntityMessage
  DelEntityMessage* = object of EntityMessage

  PhysicsMessage* = object of EntityMessage
    x*, y*, z*: float32

  RotateMessage* = object of EntityMessage
    yaw*: float32
    pitch*: float32
  MoveForwardMessage* = object of EntityMessage
  MoveBackwardMessage* = object of EntityMessage
  MoveLeftMessage* = object of EntityMessage
  MoveRightMessage* = object of EntityMessage


registerWithStringify(ConnectMessage)
registerWithStringify(LoadSceneMessage)

registerWithStringify(AddEntityMessage)
registerWithStringify(DelEntityMessage)
registerWithStringify(PhysicsMessage)

registerWithStringify(RotateMessage)
registerWithStringify(MoveForwardMessage)
registerWithStringify(MoveBackwardMessage)
registerWithStringify(MoveLeftMessage)
registerWithStringify(MoveRightMessage)
