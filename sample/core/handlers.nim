import c4.core.states
import c4.wrappers.enet.enet
import c4.systems.network
import c4.config
import c4.defaults.states as default_states

import messages


method handleMessage*(self: ref NetworkSystem, message: ref LoadSceneMessage, peer: enet.Peer, channelId: uint8) =
  config.state.switch(new(LoadingServerState))
