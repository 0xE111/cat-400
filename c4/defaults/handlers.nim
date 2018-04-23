import logging

import "../config"
import "../core/states"
import "../systems"
import "../systems/network"
import "../systems/video"

import messages as default_messages
import states as default_states


method store*(self: ref NetworkSystem, message: ref QuitMessage) =
  # by default network system sends all local incoming messages
  # however, we want to store and process QuitMessage
  procCall ((ref System)self).store(message)

method process*(self: ref NetworkSystem, message: ref QuitMessage) =
  self.disconnect()
  config.state.switch(new(FinalState))

method process*(self: ref VideoSystem, message: ref WindowResizeMessage) =
  self.updateViewport(message.width, message.height)
