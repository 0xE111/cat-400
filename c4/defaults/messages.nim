import "../wrappers/msgpack/msgpack"
import typetraits

from "../core/messages" import Message
from "../core/entities" import Entity
from "../systems/physics" import Physics


type
  QuitMessage* = object of Message
  ## This message is a signal to disconnect and terminate process


register(Message, QuitMessage)
method `$`(self: ref QuitMessage): string = "QuitMessage"
