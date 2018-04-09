from logging import Level
from utils.loading import load

from core.states import State

from systems.input import InputSystem
from systems.network import NetworkSystem
from systems.video import VideoSystem, Window
from systems.physics import PhysicsSystem


var
  title* = ""
  version* = "0.0"
  logLevel* = logging.Level.lvlWarn

  state*: ref State  # TODO: move to app?

  systems* = (
    physics: (
      instance: new(ref PhysicsSystem),
    ),
    input: (
      instance: new(ref InputSystem),
    ),
    network: (
      instance: new(ref NetworkSystem),
      port: 11477'u16,
    ),
    video: (
      instance: new(ref VideoSystem),
      window: (
        x: 400,
        y: 400,
        width: 600,
        height: 400,
        fullscreen: false,
      ),
    )
  )
