# const network {.strdefine.}: string = "c4/systems/network_enet"
# include "/tmp/network_custom"

include "../wrappers/enet/nimenet"
# TODO: allow to override the network system

proc update*(server: var Server, dt: float): bool =
  server.poll()
  result = true
