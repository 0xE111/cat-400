import chronicles
import chronicles/options
export chronicles

import parseopt


template withLog*(severity: LogLevel, eventName: static[string], code: untyped) =
  log(instantiationInfo(), severity, eventName)
  code
  log(instantiationInfo(), severity, eventName & " - done")


proc getProcessName(): string =
  for kind, key, value in parseopt.getopt():
    if kind == parseopt.cmdLongOption and key == "process":
      return value

  "main"


publicLogScope:
  process = getProcessName()
