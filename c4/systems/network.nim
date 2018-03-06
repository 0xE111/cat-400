# NimEnet - high-level wrapper for Enet library
import "../wrappers/enet/enet"
import logging

# ---- types ----
type
  Host* = string
  Port* = uint16
  Address* = tuple[host: Host, port: Port]

  ConnectCallback* = proc(peer: enet.Peer) {.closure.}
  ReceiveCallback* = proc(peer: enet.Peer, channelId: uint8, packet: enet.Packet) {.closure.}

var
  host: ptr enet.Host
  peers: seq[ptr enet.Peer]

  connectCallback: ConnectCallback
  disconnectCallback: ConnectCallback
  receiveCallback: ReceiveCallback
  

# ---- helpers ----
proc `$`*(address: enet.Address): string =
  $address.host & ":" & $address.port

proc `$`*(host: enet.Host): string =
  "Host: " & $host.address

proc `$`*(peer: enet.Peer): string =
  "Peer: " & $peer.address

proc `$`*(packet: ptr Packet): string =
  "Packet of size " & $packet.dataLength
    
proc remove[T](items: var seq[T], value: T) =
  let index = items.find(value)
  if index != -1:
    items.del(index)

# ---- converters ----
# proc getAddress(host: string, port: uint16): enet.Address =
#   discard enet.address_set_host(result.addr, host.cstring)
#   result.port = port

proc init*(
  port: Port = 0,
  numConnections = 32,
  numChannels = 2,
  inBandwidth = 0,
  outBandwidth = 0,
  onConnect = (proc(peer: enet.Peer) = logging.debug("Peer connected: " & $peer)),
  onDisconnect = (proc(peer: enet.Peer) = logging.debug("Peer disconnected: " & $peer)),
  onReceive = (proc(peer: enet.Peer, channelId: uint8, packet: enet.Packet) = logging.debug("Received packet " & $packet & " from peer " & $peer)),
) =
  if enet.initialize() != 0.cint:
    let err = "An error occurred during initialization"
    logging.fatal(err)
    raise newException(LibraryError, err)

  # set up address
  var addressPtr: ptr enet.Address = nil
  if port != 0:
    var address = enet.Address(host: enet.HOST_ANY, port: port)
    addressPtr = address.addr

  host = enet.host_create(addressPtr, numConnections.csize, numChannels.csize, inBandwidth.uint16, outBandwidth.uint16)
  if host == nil:
    raise newException(LibraryError, "An error occured while trying to init host")

  peers = @[]

  # set up handlers
  connectCallback = onConnect
  disconnectCallback = onDisconnect
  receiveCallback = onReceive

proc connect*(address: Address, numChannels = 1) =
  var enetAddress: enet.Address
  discard enet.address_set_host(enetAddress.addr, address.host.cstring)
  enetAddress.port = address.port

  if enet.host_connect(host, enetAddress.addr, numChannels.csize, 0.uint32) == nil:
    raise newException(LibraryError, "No available peers for initiating an ENet connection")

  # further connection success / failure is handled by onConnect / onDisconnect procs

proc disconnect*(peer: ptr enet.Peer, force = false) =
  if not force:
    enet.peer_disconnect(peer, 0)
  else:
    enet.peer_reset(peer)
    peers.remove(peer)
  
# proc pollConnection*(self: var enet.Event, connection: Connection, timeout = 0) =
#   discard enet.host_service(connection.host, addr(self), timeout.uint32)
  
proc poll*() =
  ## Check whether there is any network event and process if any
  var event: enet.Event

  while enet.host_service(host, addr(event), 0.uint32) != 0:
    # for each event type call corresponding handlers
    case event.`type`
      of EVENT_TYPE_CONNECT:
        peers.add(event.peer)
        connectCallback(event.peer[])
      of EVENT_TYPE_RECEIVE:
        receiveCallback(event.peer[], event.channelID, event.packet[])
        enet.packet_destroy(event.packet)
      of EVENT_TYPE_DISCONNECT:
        disconnectCallback(event.peer[])
        peers.remove(event.peer)
      else:
        discard

proc send*(
  peer: ptr enet.Peer = nil,  # set nil to broadcast
  channelId:uint8 = 0,
  data: string,
  reliable = false,
  immediate = false
) =
  var packet = enet.packet_create(
    data.cstring,
    (data.cstring.len + 1).csize,
    if reliable: enet.PACKET_FLAG_RELIABLE else: enet.PACKET_FLAG_UNRELIABLE,
  )

  if peer == nil:  # broadcast
    enet.host_broadcast(host, channelId, packet)
  else:
    discard enet.peer_send(peer, channelId, packet)

  if immediate:
    enet.host_flush(host)

proc release*() =
  enet.host_destroy(host)
  enet.deinitialize()
