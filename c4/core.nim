from posix import fork
from parseopt import nil
from logging import nil
from ospaths import joinPath
from osproc import startProcess, running, terminate, ProcessOption
from os import getAppDir, getAppFilename, commandLineParams, sleep

from strutils import join, toLowerAscii, toUpperAscii, parseEnum
from strformat import `&`
from utils.helpers import index
from sequtils import mapIt

from conf import config
from server import run
import core.states
from client import run


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
      sleep(1000 * 2)
    
    clientProcess.terminate()
    serverProcess.terminate()
    return

  let
    logFile = joinPath(getAppDir(), (if mode == Mode.server: "server.log" else: "client.log"))
    logFmtStr = "[$datetime] " & (if mode == Mode.server: "SERVER" else: "CLIENT") & " $levelname: "
  logging.addHandler(logging.newRollingFileLogger(logFile, maxLines=1000, levelThreshold=config.logLevel, fmtStr=logFmtStr))
  logging.addHandler(logging.newConsoleLogger(levelThreshold=config.logLevel, fmtStr=logFmtStr))
  logging.debug("Version " & frameworkVersion)

  if mode == Mode.server:
    server.state.switch(new(server.InitialState))
    server.run()
  else:
    client.run(config)
