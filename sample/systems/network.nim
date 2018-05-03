import logging
from strformat import `&`

import c4.config
import c4.core.states
import c4.presets.default.states as default_states
import c4.systems
import c4.systems.network
import c4.core.messages as c4_messages
import c4.presets.default.messages as default_messages

import "../core/messages"


method process(self: ref NetworkSystem, message: ref LoadSceneMessage) =
  # processing incoming LoadScene message
  config.state.switch(new(LoadingServerState))

method store(self: ref NetworkSystem, message: ref ConnectMessage) =
  # by default network system sends all local incoming messages
  # however, we want to store and process ConnectMessage
  procCall ((ref System)self).store(message)

method process(self: ref NetworkSystem, message: ref ConnectMessage) =
  if not message.isExternal:
    logging.debug &"Connecting to port {config.settings.network.port}"
    self.connect(("localhost", config.settings.network.port))

method process(self: ref NetworkSystem, message: ref AddEntityMessage) =
  message.send(config.systems.video)

method process(self: ref NetworkSystem, message: ref PhysicsMessage) =
  message.send(config.systems.video)
