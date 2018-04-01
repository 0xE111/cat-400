import "../core/messages"
import "../core/messages/builtins"
import "../core/states"

import "../wrappers/enet/enet"
import "../wrappers/msgpack/msgpack"

import "../systems/network"

import "../server"


method handleMessage*(self: ref NetworkSystem, message: ref QuitMessage, peer: enet.Peer, channelId: uint8) =
  server.state.switch(new(FinishingState))
