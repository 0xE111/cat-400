from parseopt2 import getopt, cmdLongOption, cmdShortOption
from posix import fork

proc printHelp() =
  echo """
    Help
    -v, --version - print version
    -d, --debug - enable debug mode
    -h, --help - print help
  """

var debug = false;
proc enableDebug() =
  debug = true

const version = "0.1"
proc printVersion() =
  echo version

proc main() =
  for kind, key, val in getopt():
    case kind
      of cmdLongOption, cmdShortOption:
        case key
          of "version", "v":
            printVersion()
            return
          of "debug", "d":
            enableDebug()
          of "help", "h":
            printHelp()
            return
          else: echo "Unknown option: " , key , "=" , val
      else: discard

  let pid = fork()
  if pid < 0:
    raise newException(SystemError, "Error forking a process")
  elif pid > 0:
    echo "I am a parent, my child's pid is ", $(pid)
    while true:
      echo "Parent"
  else:
    echo "I am a child, my pid is ", $(pid)
    while true:
      echo "Child"


when isMainModule:
  main()
