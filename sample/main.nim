from c4.core import config, run
import server.server_states, client.client_states

config.version = "0.1"

when isMainModule:
  run()
