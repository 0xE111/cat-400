import chronicles
import chronicles/options
export chronicles

import ./processes


template withLog*(severity: LogLevel, eventName: static[string], code: untyped) =
  log(instantiationInfo(), severity, eventName)
  code
  log(instantiationInfo(), severity, eventName & " - done")


publicLogScope:
  process = getProcessName()
