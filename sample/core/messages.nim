from c4.core.messages import Message
import c4.wrappers.msgpack.msgpack


type
  CustomMessage* = object of Message
    data*: int8

method `$`*(self: ref CustomMessage): string = "Custom"
register(Message, CustomMessage)
