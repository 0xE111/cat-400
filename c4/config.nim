from logging import Level
from utils.loading import load

from core.states import State
from systems as systems_module import System


var
  title* = ""
  version* = "0.0"
  logLevel* = logging.Level.lvlWarn

  state*: ref State  # TODO: move to app?

  systems* = (
    network: (ref System)(nil),
    input: (ref System)(nil),
    video: (ref System)(nil),
    physics: (ref System)(nil),
  )

  settings* = (
    network: (
      port: 11477'u16,
      serverMode: true,
    ),
    video: (
      window: (
        x: 400,
        y: 400,
        width: 600,
        height: 400,
        fullscreen: false,
      ),
    ),
  )
