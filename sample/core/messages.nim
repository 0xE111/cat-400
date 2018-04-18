import c4.core.messages
import c4.wrappers.enet.enet
import c4.wrappers.msgpack.msgpack
import c4.systems.physics
import typetraits


type
  ConnectMessage* = object of Message
  LoadSceneMessage* = object of Message
  
  AddEntityMessage* = object of EntityMessage
  DelEntityMessage* = object of EntityMessage

  PhysicsMessage* = object of EntityMessage
    physics*: ref Physics

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
