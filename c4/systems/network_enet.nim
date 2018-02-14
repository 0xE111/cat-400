import logging
import network
import ../wrappers/enet/nimenet


template debug(message: string) =
  logging.debug("Enet network: " & message)


type
  EnetServerNetwork* = object of ServerNetwork
    server: ptr Server

  EnetClientNetwork* = object of ClientNetwork
    client: ptr Client
    server: ptr Server


# ---- Server implementation ----
method init*(self: ref EnetServerNetwork, port: uint16) =
  init()
  self.server = newServer(port = port)
  debug("Server started: " & $self.server[])

method destroy*(self: ref EnetServerNetwork) =
  destroy()

method update*(self: ref EnetServerNetwork, dt: float): bool =
  result = true

  # var event: enet.Event
  # if enet.host_service(self.host, addr(event), 0.uint32) == 0:
  #   return
  #
  # case event.`type`
  #   of EVENT_TYPE_CONNECT:
  #     debug("New peer connected: " & $event.peer)
  #   of EVENT_TYPE_RECEIVE:
  #     debug("Received packet [" & $event.packet & "] from peer " & $event.peer)
  #     enet.packet_destroy(event.packet)
  #   of EVENT_TYPE_DISCONNECT:
  #     debug("Peer disconnected: " & $event.peer)
  #   of EVENT_TYPE_NONE:
  #     discard


# ---- Client implementation ----
method init*(self: ref EnetClientNetwork) =
  init()
  self.client = newClient()
  debug("Client started: " & $self.client[])

method destroy*(self: ref EnetClientNetwork) =
  destroy()

# method connect*(self: ref EnetClientNetwork, host: Host, port: Port) =
#   var address = getAddress(host, port)

#   var
#     data = "test data"
#     packet = createPacket(data)
  
#   enet.peer_send()