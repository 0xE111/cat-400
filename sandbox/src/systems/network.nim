import logging

import c4.config
import c4.systems
import c4.core.messages
import c4.systems.network.enet
import c4.presets.action.systems.network


type
  SandboxNetworkSystem* = object of ActionNetworkSystem
