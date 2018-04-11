import logging
from strformat import `&`

import c4.config
import c4.core.states
import c4.defaults.states as default_states
import c4.systems.network
import c4.core.messages as c4_messages

import "../core/messages"


method process(self: ref NetworkSystem, message: ref LoadSceneMessage) =
  if message.isExternal:
    # processing incoming LoadScene message
    config.state.switch(new(LoadingServerState))
  else:  # outgoing
    self.send(message)

method process(self: ref NetworkSystem, message: ref ConnectMessage) =
  if not message.isExternal:
    logging.debug &"Connecting to port {config.settings.network.port}"
    self.connect(("localhost", config.settings.network.port))
