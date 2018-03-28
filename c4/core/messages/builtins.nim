import "../../wrappers/msgpack/msgpack"
import typetraits

from "../messages" import Message
from "../entities" import Entity
from "../../systems/physics" import Physics


type
  QuitMessage* = object of Message

  EntityMessage* = object of Message
    entity*: Entity
  AddEntityMessage* = object of EntityMessage
  DelEntityMessage* = object of EntityMessage

  PhysicsMessage* = object of Message
    physics*: ref Physics


template reg(t: typedesc): untyped =
  method `$`*(self: ref t): string = t.name
  register(Message, t)

reg(QuitMessage)
reg(AddEntityMessage)
reg(DelEntityMessage)
reg(PhysicsMessage)
