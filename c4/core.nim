from parseopt import nil
import logging
from osproc import startProcess, running, kill, ProcessOption
from os import getAppDir, getAppFilename, commandLineParams, sleep, joinPath
import tables

from strutils import join, toLowerAscii, toUpperAscii, parseEnum
from strformat import `&`
from sequtils import mapIt

import config
import app


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


proc run*() =
  ## Handles CLI args, sets up logging and runs client / server / overseer process.
  ##
  ## Run this in your main module.

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
            config.logLevel = parseEnum[logging.Level](&"lvl{value}")
          of "help", "h":
            echo help
            return
          of "mode", "m":
            config.mode = parseEnum[Mode](value)
          else:
            echo "Unknown option: " & key & "=" & value
            return
      else: discard

  # TODO: add logger helper - include file name (and possibly line) in log message
  let
    logFile = joinPath(getAppDir(), &"{mode}.log")
    logFmtStr = &"[$datetime] {mode} $levelname: "
  logging.addHandler(logging.newRollingFileLogger(logFile, maxLines=1000, levelThreshold=config.logLevel, fmtStr=logFmtStr))
  logging.addHandler(logging.newConsoleLogger(levelThreshold=config.logLevel, fmtStr=logFmtStr))
  logging.debug("Version " & frameworkVersion)

  if config.mode == Mode.multi:
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

  app.run()
