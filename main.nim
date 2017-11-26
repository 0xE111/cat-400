from strutils import format
from sequtils import mapIt
from posix import fork
from system import staticExec

from parseopt2 import nil
from logging import nil

from utils import join, index


const 
  version = staticExec("git describe --long --tags")
  help = """
    -v, --version - print version
    --loglevel=[$logLevels] - specify log level
    -h, --help - print help
    -s, --server - launch server only (without client)
  """.format([
    "logLevels", logging.LevelNames.join("|"),
  ])

var 
  logLevel = logging.Level.lvlWarn  # default log level
  serverMode = false  # launch both server and client by default

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
            echo help
            return
          of "server", "s":
            serverMode = true
          else:
            echo "Unknown option: " , key , "=" , val
            return
      else: discard

  # separate this process into "client" and "server" processes
  let
    pid = (if serverMode: 0 else: fork())
    is_server_process = (if pid == 0: true else: false)
 
  if pid < 0:
    raise newException(SystemError, "Error forking a process")

  # the following code will be executed by both processes
  # set up logging
  let
    logFile = (if is_server_process: "server.log" else: "client.log")
    logFmtStr = "[$datetime] $levelname: "
  logging.addHandler(logging.newRollingFileLogger(logFile, maxLines=1000, levelThreshold=logLevel, fmtStr=logFmtStr))
  logging.addHandler(logging.newConsoleLogger(levelThreshold=logLevel, fmtStr=logFmtStr))
  logging.debug("Version " & version)

  if is_server_process:
    logging.debug("Server process instantiated")
    while true:
      echo "server"
  else:
    logging.debug("Client process instantiated, pid=$pid".format(["pid", $pid]))
    while true:
      echo "client"

when isMainModule:
  main()
