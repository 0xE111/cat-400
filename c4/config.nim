## This is a global config for the framework. You may change any of the settings by direct assignment: ``config.title = "Your game title"``

import logging
import tables
import strformat

import systems as systems_module


type
  Mode* = enum
    ## Mode of the process
    client, server, multi


var
  # you don't need to modify following settings explicitly unless you know what you are doing
  logLevel* = logging.Level.lvlWarn
  mode* = Mode.multi

  # here you may override default systems with your custom ones
  serverSystems* = initOrderedTable[string, ref System]()
  clientSystems* = initOrderedTable[string, ref System]()

  # do not touch this
  systems*: OrderedTable[string, ref System]

# TODO: check how this affects performance
# proc getSystems*(): OrderedTable[string, ref System] =
#   ## Returns systems table with respect to current mode
#   case mode
#     of Mode.server:
#       result = serverSystems

#     of Mode.client:
#       result = clientSystems

#     else:
#       raise newException(LibraryError, &"Cannot get systems table in {mode} mode")
