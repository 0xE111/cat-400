from strutils import format
from sequtils import mapIt
from posix import fork
from system import staticExec

from parseopt2 import nil
from logging import nil

from utils import join, index


proc printHelp() =
  echo """
    Help
    -v, --version - print version
    --loglevel=[$logLevels] - specify log level
    -h, --help - print help
  """.format([
    "logLevels", logging.LevelNames.join("|"),
  ])

const version = staticExec("git describe --long --tags")

var
  logLevel = logging.Level.lvlWarn

proc main() =
  # parse command line options
  for kind, key, val in parseopt2.getopt():
    case kind
      of parseopt2.cmdLongOption, parseopt2.cmdShortOption:
        case key
          of "version", "v":
            echo version
            return
          of "loglevel":
            logLevel = logging.LevelNames.index(val)  # overwrite default log level
          of "help", "h":
            printHelp()
            return
          else:
            echo "Unknown option: " , key , "=" , val
            return
      else: discard

  # separate this process into "client" and "server" processes
  let
    pid = fork()

  var is_server_process: bool
  if pid > 0:
    is_server_process = true
  elif pid == 0:
    is_server_process = false
  else:
    raise newException(SystemError, "Error forking a process")
  # let is_server_process = (if pid > 0: true else: false)

  # the following code will be executed by both processes
  # set up logging
  let
    logFile = (if is_server_process: "server.log" else: "client.log")
    logFmtStr = "[$datetime] $levelname: "
  logging.addHandler(logging.newRollingFileLogger(logFile, maxLines=1000, levelThreshold=logLevel, fmtStr=logFmtStr))
  logging.addHandler(logging.newConsoleLogger(levelThreshold=logLevel, fmtStr=logFmtStr))
  logging.debug("Version " & version)

  if is_server_process:
    # server process
    logging.debug("Server process instantiated")
    
  else:
    # client process
    logging.debug("Client process instantiated")
    

when isMainModule:
  main()
