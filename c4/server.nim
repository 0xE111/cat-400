from logging import debug
from utils.loop import runLoop
from conf import Config
from systems.network import init, update
from systems.physics import init, update, Physics
from core.scene import Scene, loadTestData


proc run*(config: Config) =
  logging.debug("Starting server")
 
  var network = config.systems.network.instance
  network.init(port=config.systems.network.port)

  var physics = config.systems.physics.instance
  physics.init()


  var scene = Scene()
  scene.loadTestData()

  runLoop(
    updatesPerSecond = 30,
    maxFrequencyCallback = proc(dt: float): bool =
      physics.update(dt)
      network.update(dt)
      return true,
  )

  logging.debug("Server shutdown")
