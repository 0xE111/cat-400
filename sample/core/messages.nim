from c4.core.messages import Message
import c4.wrappers.msgpack.msgpack


type
  LoadSceneMessage* = object of Message

method `$`*(self: ref LoadSceneMessage): string = "LoadScene"
register(Message, LoadSceneMessage)


from logging import debug
from strformat import `&`

import c4.systems.network
import c4.wrappers.enet.enet
from c4.server import load

method handleMessage*(self: ref NetworkSystem, message: ref LoadSceneMessage, peer: enet.Peer, channelId: uint8) =
  server.load()
