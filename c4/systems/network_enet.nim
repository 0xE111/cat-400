import logging
import network
import ../wrappers/enet/enet


template debug(message: string) =
  logging.debug("Enet network: " & message)


type
  EnetServerNetwork* = object of ServerNetwork
    host: ptr enet.Host

  EnetClientNetwork* = object of ClientNetwork
    host: ptr enet.Host
    server: enet.Address


# ---- Helpers ----
proc initEnet() =
  if enet.initialize() != 0.cint:
    let err = "An error occurred during initialization"
    debug(err)
    raise newException(LibraryError, err)
  debug("Initialization successful")

proc destroyEnet() =
  enet.deinitialize()
  debug("Deinitialization successful")

proc createHost(address: ptr enet.Address, numClients = 32, numChannels = 2, inBandwidth = 0, outBandwidth = 0): ptr enet.Host =
  result = enet.host_create(address, numClients.csize, numChannels.csize, inBandwidth.uint32, outBandwidth.uint32)
  if result == nil:
    let err = "An error occured while trying to create a server"
    debug(err)
    raise newException(LibraryError, err)

proc `$`*(host: ptr enet.Host): string =
  $host.address.host & ":" & $host.address.port

proc `$`*(peer: ptr enet.Peer): string =
  $peer.address

proc `$`*(packet: ptr Packet): string =
  "[" & $packet.dataLength & "]"


# ---- Server implementation ----
method init*(self: ref EnetServerNetwork, port = enet.PORT_ANY) =
  initEnet()
  var address = enet.Address(host: enet.HOST_ANY, port: port)  # TODO: is this approach correct?
  self.host = createHost(addr(address))
  debug("Server started: " & $self.host)

method destroy*(self: ref EnetServerNetwork) =
  destroyEnet()

method update*(self: ref EnetServerNetwork, dt: float): bool =
  result = true

  var event: enet.Event
  if enet.host_service(self.host, addr(event), 0.uint32) == 0:
    return

  case event.`type`
    of EVENT_TYPE_CONNECT:
      debug("New peer connected: " & $event.peer)
    of EVENT_TYPE_RECEIVE:
      debug("Received packet [" & $event.packet & "] from peer " & $event.peer)
      enet.packet_destroy(event.packet)
    of EVENT_TYPE_DISCONNECT:
      debug("Peer disconnected: " & $event.peer)
    of EVENT_TYPE_NONE:
      discard



# ---- Client implementation ----
method init*(self: ref EnetClientNetwork) =
  initEnet()
  self.host = createHost(nil, numClients=1.csize)
  debug("Client started: " & $self.host)

method destroy*(self: ref EnetClientNetwork) =
  destroyEnet()
