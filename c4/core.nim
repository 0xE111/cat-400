from strutils import format
from posix import fork
from parseopt2 import nil
from logging import nil

from utils.helpers import join, index

from conf import config, Mode
from server import Server, run
from client import Client, run


const 
  frameworkVersion = staticRead("version.txt")
  help = """
    -v, --version - print version
    --loglevel=[$logLevels] - specify log level
    -h, --help - print help
    -s, --server - launch server only (without client)
  """.format([
    "logLevels", logging.LevelNames.join("|"),
  ])

proc run*() =
  # parse command line options
  for kind, key, val in parseopt2.getopt():
    case kind
      of parseopt2.cmdLongOption, parseopt2.cmdShortOption:
        case key
          of "version", "v":
            echo("Nim version " & NimVersion)
            echo("Framework version " & frameworkVersion)
            echo("Project version " & config.version)
            return
          of "loglevel":
            config.logLevel = logging.LevelNames.index(val)  # overwrite default log level
          of "help", "h":
            echo help
            return
          of "server", "s":
            config.mode = Mode.server
          else:
            echo("Unknown option: " & key & "=" & val)
            return
      else: discard

  # separate this process into "client" and "server" processes
  # TODO: `fork()` is available in Unix only; user some other function
  let
    childPid = if config.mode == Mode.server: 1 else: fork()
    isServerProcess = childPid != 0
 
  if childPid < 0:
    raise newException(SystemError, "Error forking a process")

  # the following code will be executed by both processes

  # set up logging
  # TODO: make log files appear in the same dir as execulable, not in current dir
  let
    logFile = if isServerProcess: "server.log" else: "client.log"
    logFmtStr = "[$datetime] " & (if isServerProcess: "SERVER" else: "CLIENT") & " $levelname: "
  logging.addHandler(logging.newRollingFileLogger(logFile, maxLines=1000, levelThreshold=config.logLevel, fmtStr=logFmtStr))
  logging.addHandler(logging.newConsoleLogger(levelThreshold=config.logLevel, fmtStr=logFmtStr))
  logging.debug("Version " & frameworkVersion)

  # TODO: no way to check whether any of processes was killed (but they should be killed simultaneously)
  # TODO: addQuitProc?
  if isServerProcess:
    var server = new(ref Server)
    server.run(config=config.server)
  else:
    var client = new(ref Client)
    client.run(config=config.client)
