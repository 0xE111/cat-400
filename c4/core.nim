from parseopt import nil
import logging
from osproc import startProcess, running, kill, ProcessOption
from os import getAppDir, getAppFilename, commandLineParams, sleep, joinPath
import tables

from strutils import join, toLowerAscii, toUpperAscii, parseEnum
from strformat import `&`
from sequtils import mapIt

import systems as systems_module
import utils/loop


type Mode = enum client, server, multi

# TODO: use `finalizer` kw for every `new()` call
const
  frameworkVersion = staticRead("version.txt")

  logLevels = logging.Level.mapIt(($it)[3..^1].toLowerAscii).join("|")
  modes = Mode.mapIt($it).join("|")
  help = &"""
    -v, --version - print version
    -l, --loglevel=[{logLevels}] - specify log level
    -h, --help - print help
    -m, --mode=[{modes}] - launch server/client/both
  """

var systems* = initOrderedTable[string, ref System]()  ## variable which stores all active systems for current process (mode)

proc run*(serverSystems, clientSystems = initOrderedTable[string, ref System]()) =
  ## Handles CLI args, sets up logging and runs client / server / overseer process.
  ##
  ## Run this in your main module.

  # default values
  var
    logLevel = logging.Level.lvlWarn
    mode = Mode.multi

  # TODO: use https://github.com/c-blake/cligen?
  for kind, key, value in parseopt.getopt():
    case kind
      of parseopt.cmdLongOption, parseopt.cmdShortOption:
        case key
          of "version", "v":
            echo "C4 " & frameworkVersion
            echo "Nim " & NimVersion
            echo "Compiled @ " & CompileDate & " " & CompileTime
            return
          of "loglevel", "l":
            logLevel = parseEnum[logging.Level](&"lvl{value}")
          of "help", "h":
            echo help
            return
          of "mode", "m":
            mode = parseEnum[Mode](value)
          else:
            echo "Unknown option: " & key & "=" & value
            return
      else: discard

  # TODO: add logger helper - include file name (and possibly line) in log message
  let
    logFile = joinPath(getAppDir(), &"{mode}.log")
    logFmtStr = &"[$datetime] {mode} $levelname: "
  logging.addHandler(logging.newRollingFileLogger(logFile, maxLines=1000, levelThreshold=logLevel, fmtStr=logFmtStr))
  logging.addHandler(logging.newConsoleLogger(levelThreshold=logLevel, fmtStr=logFmtStr))
  logging.debug("Version " & frameworkVersion)

  # this part of code handles spawning & maintaining client & server subprocesses
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

  ## this part of code initializes systems and runs game loop
  logging.debug &"Starting {mode} process"

  systems = if mode == Mode.server: serverSystems else: clientSystems
  try:
    for systemName, system in systems.pairs:
      logging.debug &"Initializing {systemName}"
      system.init()
      new(SystemReadyMessage).send(system)

    logging.debug "Starting main loop"

    runLoop(
      updatesPerSecond = 60,
      fixedFrequencyCallback = proc(dt: float): bool =  # TODO: maxFrequencyCallback?
        for system in systems.values():
          system.update(dt)
        true  # TODO: how to quit?
    )

  except Exception as exc:
    # log any exception from client/server before dying
    logging.fatal &"Exception: {exc.msg}\n{exc.getStackTrace()}"
    raise

  # TODO: GC supports real-time mode which this library makes use of. It means the GC will never run during game frames and will use fixed amount of frame idle time to collect garbage. This leads to no stalls and close to zero compromise on performance comparing to native languages with manual memory management.

  logging.debug "Finishing process"
