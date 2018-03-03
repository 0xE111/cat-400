# NimEnet - high-level wrapper for Enet library
import nimenet.enet
import logging

# ---- types ----
type
  Host* = string
  Port* = uint16
  Address* = tuple[host: Host, port: Port]

  Client* = object
    host: ptr enet.Host
    peers: seq[ptr enet.Peer]

    onConnect: proc(peer: enet.Peer)
    onDisconnect:  proc(peer: enet.Peer)
    onReceive: proc(peer: enet.Peer, channelId: uint8, packet: enet.Packet)
  
# ---- vars ----
var clientsCount = 0  # init enet when clientsCount > 0, deinit when == 0

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


# ---- global ----
proc init*() =
  ## Init library
  if enet.initialize() != 0.cint:
    let err = "An error occurred during initialization"
    logging.fatal(err)
    raise newException(LibraryError, err)

proc deinit*() =
  ## Shutdown library
  enet.deinitialize()

proc onConnect(peer: enet.Peer) =
  logging.debug("Peer connected: " & $peer)

proc onDisconnect(peer: enet.Peer) =
  logging.debug("Peer disconnected: " & $peer)

proc onReceive(peer: enet.Peer, channelId: uint8, packet: enet.Packet) =
  logging.debug("Received packet " & $packet & " from peer " & $peer)

proc init*(
  self: var Client,
  port: Port = 0,
  numConnections = 32,
  numChannels = 2,
  inBandwidth = 0,
  outBandwidth = 0,
  onConnect = onConnect,
  onDisconnect = onDisconnect,
  onReceive = onReceive,
) =
  # init enet library if needed
  if clientsCount == 0:
    init()
  clientsCount += 1

  # set up address
  var addressPtr: ptr enet.Address = nil
  if port != 0:
    var address = enet.Address(host: enet.HOST_ANY, port: port)
    addressPtr = address.addr

  self.host = enet.host_create(addressPtr, numConnections.csize, numChannels.csize, inBandwidth.uint16, outBandwidth.uint16)
  if self.host == nil:
    raise newException(LibraryError, "An error occured while trying to init host")

  self.peers = @[]

  # set up handlers
  self.onConnect = onConnect
  self.onDisconnect = onDisconnect
  self.onReceive = onReceive

proc connect*(self: var Client, address: Address, numChannels = 1) =
  var enetAddress: enet.Address
  discard enet.address_set_host(enetAddress.addr, address.host.cstring)
  enetAddress.port = address.port

  if enet.host_connect(self.host, enetAddress.addr, numChannels.csize, 0.uint32) == nil:
    raise newException(LibraryError, "No available peers for initiating an ENet connection")

  # further connection success / failure is handled by onConnect / onDisconnect procs

proc disconnect*(self: var Client, peer: ptr enet.Peer, force = false) =
  if not force:
    enet.peer_disconnect(peer, 0)
  else:
    enet.peer_reset(peer)
    self.peers.remove(peer)
  
# proc pollConnection*(self: var enet.Event, connection: Connection, timeout = 0) =
#   discard enet.host_service(connection.host, addr(self), timeout.uint32)
  
proc poll*(self: var Client) =
  ## Check whether there is any network event and process if any
  var event: enet.Event
  if enet.host_service(self.host, addr(event), 0.uint32) == 0:
    return
  
  # for each event type call corresponding handlers
  case event.`type`
    of EVENT_TYPE_CONNECT:
      self.peers.add(event.peer)
      self.onConnect(event.peer[])
    of EVENT_TYPE_RECEIVE:
      self.onReceive(event.peer[], event.channelID, event.packet[])
      enet.packet_destroy(event.packet)
    of EVENT_TYPE_DISCONNECT:
      self.onDisconnect(event.peer[])
      self.peers.remove(event.peer)
    else:
      discard

proc send*(
  self: Client,
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
    enet.host_broadcast(self.host, channelId, packet)
  else:
    discard enet.peer_send(peer, channelId, packet)

  if immediate:
    enet.host_flush(self.host)


{.experimental.}
proc `=destroy`(self: var Client) =
  enet.host_destroy(self.host)

  clientsCount -= 1
  if clientsCount == 0:
    deinit()

# proc createPacket(data: string, kind=enet.PACKET_FLAG_UNRELIABLE_FRAGMENT): ptr enet.Packet =
# var data = 
# result = enet.packet_create(data.addr, data.len.csize, kind)
