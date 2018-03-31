from logging import debug
from utils.loop import runLoop
from conf import Config
from systems.network import init, update
from systems.physics import init, update, Physics
import core.entities
import core.messages, core.messages.builtins
from core.states import State, onLeave, onEnter


type
  InitialState* = object of State
  LoadingState* = object of State

var state*: ref State = new(InitialState)


proc run*(config: Config) =
  logging.debug("Starting server")
 
  var network = config.systems.network.instance
  network.init(port=config.systems.network.port)

  var physics = config.systems.physics.instance
  physics.init()

  runLoop(
    updatesPerSecond = 30,
    maxFrequencyCallback = proc(dt: float): bool =
      physics.update(dt)
      network.update(dt)
      return true,
  )

  logging.debug("Server shutdown")
