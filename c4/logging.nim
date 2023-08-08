import chronicles
import chronicles/options
export chronicles


template withLog*(severity: LogLevel, eventName: static[string], code: untyped) =
  log(instantiationInfo(), severity, eventName)
  code
  log(instantiationInfo(), severity, eventName & " - done")
