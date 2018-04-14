import "../wrappers/msgpack/msgpack"
import typetraits

from "../core/messages" import Message
from "../core/entities" import Entity
from "../systems/physics" import Physics


type
  QuitMessage* = object of Message

  EntityMessage* = object of Message
    entity*: Entity
  AddEntityMessage* = object of EntityMessage
  DelEntityMessage* = object of EntityMessage

  PhysicsMessage* = object of EntityMessage
    physics*: ref Physics

  RotationMessage* = object of EntityMessage
    yaw*: float32
    pitch*: float32


template reg(t: typedesc): untyped =
  method `$`*(self: ref t): string = t.name
  register(Message, t)

reg(QuitMessage)
reg(AddEntityMessage)
reg(DelEntityMessage)
reg(PhysicsMessage)
reg(RotationMessage)
