import c4.conf
import c4.core

import systems.physics
import systems.input

# here we import our custom definitions and methods
import core.messages
import core.handlers
import core.states


config.title = "Sample game"
config.version = "0.1"
config.systems.input.instance = new(ref CustomInputSystem)


when isMainModule:
  core.run()
