from logging import debug
from utils.loop import runLoop
from conf import Config
from systems.network import init, update
from systems.physics import init, update, Physics
import core.entities
import core.messages, core.messages.builtins


proc load() =
  let player = newEntity()  # create new entity
  (ref AddEntityMessage)(entity: player).broadcast()  # send message

  player[ref Physics] = (ref Physics)(x: 0, y: 0, z: 0)  # init physics for player
  (ref PhysicsMessage)(physics: player[ref Physics]).broadcast()
  player[ref Physics].x = 1  # update player physics
  (ref PhysicsMessage)(physics: player[ref Physics]).broadcast()

  let cube = newEntity()
  (ref AddEntityMessage)(entity: cube).broadcast()

  cube[ref Physics] = (ref Physics)(x: 0, y: 0, z: -5)
  (ref PhysicsMessage)(physics: player[ref Physics]).broadcast()


proc run*(config: Config) =
  logging.debug("Starting server")
 
  var network = config.systems.network.instance
  network.init(port=config.systems.network.port)

  var physics = config.systems.physics.instance
  physics.init()

  load()

  runLoop(
    updatesPerSecond = 30,
    maxFrequencyCallback = proc(dt: float): bool =
      physics.update(dt)
      network.update(dt)
      return true,
  )

  logging.debug("Server shutdown")
