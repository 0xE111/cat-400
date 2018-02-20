import logging
import ../wrappers/enet/nimenet


template debug(message: string) =
  logging.debug("Enet network: " & message)


type
  NetworkServer* = object
    host: ptr Server

  NetworkClient* = object
    host: ptr Client
    server: ptr Server


# ---- Server implementation ----
proc init*(self: var NetworkServer, port: uint16) =
  init()
  self.server = newServer(port = port)
  debug("Server started: " & $self.server[])

proc destroy*(self: NetworkServer) =
  destroy()

proc update*(self: NetworkServer, dt: float): bool =
  discard self.server.poll()
  result = true


# ---- Client implementation ----
proc init*(self: var NetworkClient) =
  init()
  self.client = newClient()
  debug("Client started: " & $self.client[])

proc destroy*(self: NetworkClient) =
  destroy()

proc update*(self: NetworkClient, dt: float): bool =
  discard self.client.poll()
  result = true

# method connect*(self: ref EnetNetworkClient, host: Host, port: Port) =
#   var address = getAddress(host, port)

#   var
#     data = "test data"
#     packet = createPacket(data)
  
#   enet.peer_send()