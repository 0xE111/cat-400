import c4.core.messages
import c4.wrappers.enet.enet
import c4.wrappers.msgpack.msgpack
import typetraits
import c4.systems.physics


type
  ConnectMessage* = object of Message
  LoadSceneMessage* = object of Message
  
  AddEntityMessage* = object of EntityMessage
  DelEntityMessage* = object of EntityMessage

  PhysicsMessage* = object of EntityMessage
    physics*: ref Physics

  RotationMessage* = object of EntityMessage
    yaw*: float32
    pitch*: float32
  
  ForwardMessage* = object of EntityMessage
  BackwardMessage* = object of EntityMessage


registerWithStringify(ConnectMessage)
registerWithStringify(LoadSceneMessage)

registerWithStringify(AddEntityMessage)
registerWithStringify(DelEntityMessage)
registerWithStringify(PhysicsMessage)
registerWithStringify(RotationMessage)
