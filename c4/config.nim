## This is a global config for the framework. You may change any of the settings by direct assignment: ``config.title = "Your game title"``

import logging
import tables

import systems as systems_module


type
  Mode* = enum
    ## Mode of the process
    client, server, multi


var
  # you don't need to modify following settings explicitly unless you know what you are doing
  logLevel* = logging.Level.lvlWarn
  mode* = Mode.multi

  # these are configurable settings
  title* = ""
  version* = "0.0"

  # here you may override default systems with your custom ones
  serverSystems* = initOrderedTable[string, ref System]()
  clientSystems* = initOrderedTable[string, ref System]()

  # do not modify this
  systems* = initOrderedTable[string, ref System]()

  # here are parameters for systems initialization
  settings* = (
    network: (
      port: 11477'u16,
    ),
    video: (
      window: (
        x: 200,
        y: 400,
        width: 800,
        height: 600,
        fullscreen: false,
      ),
    ),
  )
