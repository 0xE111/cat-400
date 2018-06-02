import strformat

import "../../core/messages"
import "../../wrappers/enet/enet"
import "../../systems/physics/ode"
import "../../utils/stringify"
import "../default/messages" as default_messages


type
  ConnectMessage* = object of Message
  LoadSceneMessage* = object of Message

  PhysicsMessage* = object of EntityMessage
    x*, y*, z*: float32

  RotateMessage* = object of EntityMessage
    yaw*: float32
    pitch*: float32
  MoveForwardMessage* = object of EntityMessage
  MoveBackwardMessage* = object of EntityMessage
  MoveLeftMessage* = object of EntityMessage
  MoveRightMessage* = object of EntityMessage


messages.register(ConnectMessage)
strMethod(ConnectMessage)

messages.register(LoadSceneMessage)
strMethod(LoadSceneMessage)

messages.register(PhysicsMessage)
method `$`*(self: ref PhysicsMessage): string = &"{self[].type.name}: {self.x}, {self.y}, {self.z} (entity {self.entity})"

messages.register(RotateMessage)
method `$`*(self: ref RotateMessage): string = &"{self[].type.name}: {self.yaw}, {self.pitch}  (entity {self.entity})"

messages.register(MoveForwardMessage)
strMethod(MoveForwardMessage)
messages.register(MoveBackwardMessage)
strMethod(MoveBackwardMessage)
messages.register(MoveLeftMessage)
strMethod(MoveLeftMessage)
messages.register(MoveRightMessage)
strMethod(MoveRightMessage)
