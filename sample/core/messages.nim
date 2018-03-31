import c4.core.messages
import c4.core.states

import c4.wrappers.enet.enet
import c4.wrappers.msgpack.msgpack

import c4.systems.network

import c4.server


type
  LoadSceneMessage* = object of Message

method `$`*(self: ref LoadSceneMessage): string = "LoadScene"
register(Message, LoadSceneMessage)


method handleMessage*(self: ref NetworkSystem, message: ref LoadSceneMessage, peer: enet.Peer, channelId: uint8) =
  server.state.switch(new(LoadingState))  # switch to loading
