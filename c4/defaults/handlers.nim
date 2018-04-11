import "../core/messages"
import "../core/states"

import "../wrappers/enet/enet"
import "../wrappers/msgpack/msgpack"

import "../systems/network"

import messages as default_messages
import states as default_states
import "../config"


method process*(self: ref NetworkSystem, message: ref QuitMessage) =
  config.state.switch(new(FinalState))
