from strutils import format
from posix import fork

from parseopt2 import nil
from logging import nil
from server import nil
from config import Config

from utils import join, index, getVersion


const 
  version = staticRead("version.txt")
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

proc run*(conf: Config) =
  # parse command line options
  for kind, key, val in parseopt2.getopt():
    case kind
      of parseopt2.cmdLongOption, parseopt2.cmdShortOption:
        case key
          of "version", "v":
            echo "Framework version " & version
            echo "Project version " & conf.version
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
    childPid = if serverMode: 1 else: fork()
    isServerProcess = childPid != 0
 
  if childPid < 0:
    raise newException(SystemError, "Error forking a process")

  # the following code will be executed by both processes
  # set up logging
  let
    logFile = if isServerProcess: "server.log" else: "client.log"
    logFmtStr = "[$datetime] $levelname: "
  logging.addHandler(logging.newRollingFileLogger(logFile, maxLines=1000, levelThreshold=logLevel, fmtStr=logFmtStr))
  logging.addHandler(logging.newConsoleLogger(levelThreshold=logLevel, fmtStr=logFmtStr))
  logging.debug("Version " & version)

  # TODO: no way to check whether any of processes was killed (but they should be killed simultaneously)
  # TODO: addQuitProc?
  if isServerProcess:
    logging.debug("Server process created")
    server.start()
  else:
    logging.debug("Client process created")
    echo "client"
