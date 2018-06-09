## This is a global config for the framework. You may change any of the settings by direct assignment: ``config.title = "Your game title"``

from logging import Level
from utils.loading import load

from systems as systems_module import System


type
  Mode* = enum
    ## Process may run in client / server / both modes
    client, server, multi


var
  # you don't need to modify following settings explicitly unless you know what you are doing
  logLevel* = logging.Level.lvlWarn
  mode* = Mode.multi  

  # these are configurable settings
  title* = ""
  version* = "0.0"

  # here you may override default systems with your custom ones
  systems* = (
    network: (ref System)(nil),
    input: (ref System)(nil),
    video: (ref System)(nil),
    physics: (ref System)(nil),
  )

  # here are parameters for systems initialization
  settings* = (
    network: (
      port: 11477'u16,
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
