import "../core/messages"
import "../core/states"

import "../wrappers/enet/enet"
import "../wrappers/msgpack/msgpack"

import "../systems/network"

import "../server"

import messages as default_messages


method handleMessage*(self: ref NetworkSystem, message: ref QuitMessage, peer: enet.Peer, channelId: uint8) =
  server.state.switch(new(FinishingState))
