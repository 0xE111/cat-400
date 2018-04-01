import c4.core.states
import c4.wrappers.enet.enet
import c4.systems.network
import c4.server

import messages


method handleMessage*(self: ref NetworkSystem, message: ref LoadSceneMessage, peer: enet.Peer, channelId: uint8) =
  server.state.switch(new(LoadingState))