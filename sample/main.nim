from c4.core import config, run
import server.state

config.version = "0.1"

when isMainModule:
  run()
