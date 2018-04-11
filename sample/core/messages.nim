import c4.core.messages
import c4.wrappers.enet.enet
import c4.wrappers.msgpack.msgpack


type
  LoadSceneMessage* = object of Message
  ConnectMessage* = object of Message

method `$`*(self: ref LoadSceneMessage): string = "LoadScene"
register(Message, LoadSceneMessage)

method `$`*(self: ref ConnectMessage): string = "Connect"
register(Message, ConnectMessage)
