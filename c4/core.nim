from posix import fork
from parseopt import nil
from logging import nil
from ospaths import joinPath
from osproc import startProcess, running, kill, ProcessOption
from os import getAppDir, getAppFilename, commandLineParams, sleep

from strutils import join, toLowerAscii, toUpperAscii, parseEnum
from strformat import `&`
from utils.helpers import index
from sequtils import mapIt

import config
import core.states
import app

import defaults.handlers as default_handlers
import defaults.states as default_states

from systems.input import InputSystem
from systems.network import NetworkSystem
from systems.video import VideoSystem, Window
from systems.physics import PhysicsSystem


type
  Mode {.pure.} = enum
    client, server, multi


const 
  frameworkVersion = staticRead("version.txt")

  logLevels = logging.LevelNames.mapIt(it.toLowerAscii).join("|")
  modes = Mode.mapIt($it).join("|")
  help = &"""
    -v, --version - print version
    -l, --loglevel=[{logLevels}] - specify log level
    -h, --help - print help
    -m, --mode=[{modes}] - launch server/client/both 
  """


proc run*() =
  var mode = Mode.multi

  # TODO: use https://github.com/c-blake/cligen?
  for kind, key, value in parseopt.getopt():
    case kind
      of parseopt.cmdLongOption, parseopt.cmdShortOption:
        case key
          of "version", "v":
            echo config.version
            echo "C4 " & frameworkVersion
            echo "Nim " & NimVersion
            echo "Compiled @ " & CompileDate & " " & CompileTime
            return
          of "loglevel", "l":
            config.logLevel = logging.LevelNames.index(value.toUpperAscii)
          of "help", "h":
            echo help
            return
          of "mode", "m":
            mode = parseEnum[Mode](value)
          else:
            echo "Unknown option: " & key & "=" & value
            return
      else: discard

  let
    logFile = joinPath(getAppDir(), &"{mode}.log")
    logFmtStr = &"[$datetime] {mode} $levelname: "
  logging.addHandler(logging.newRollingFileLogger(logFile, maxLines=1000, levelThreshold=config.logLevel, fmtStr=logFmtStr))
  logging.addHandler(logging.newConsoleLogger(levelThreshold=config.logLevel, fmtStr=logFmtStr))
  logging.debug("Version " & frameworkVersion)

  if mode == Mode.multi:
    let
      serverProcess = startProcess(
        command=getAppFilename(),
        args=commandLineParams() & "--mode=server",
        options={poParentStreams},
      )
      clientProcess = startProcess(
        command=getAppFilename(),
        args=commandLineParams() & "--mode=client",
        options={poParentStreams},
      )

    while serverProcess.running and clientProcess.running:
      sleep(1000)
    
    logging.debug "Client or server not running -> shutting down"
    if clientProcess.running:
      logging.debug "Terminating client process"
      clientProcess.kill()
    if serverProcess.running:
      logging.debug "Terminating server process"
      serverProcess.kill()

    return

  let initialState = if mode == Mode.server: new(InitialServerState) else: new(InitialClientState)
  app.run(initialState)
