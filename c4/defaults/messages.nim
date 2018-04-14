import "../wrappers/msgpack/msgpack"
import typetraits

from "../core/messages" import Message
from "../core/entities" import Entity
from "../systems/physics" import Physics


type
  QuitMessage* = object of Message


register(Message, QuitMessage)
method `$`(self: ref QuitMessage): string = "QuitMessage"
