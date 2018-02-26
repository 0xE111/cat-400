# NimEnet - high-level wrapper for Enet library
import nimenet.enet
import logging

# ---- types ----
type
  Host* = string
  Port* = uint16
  Address* = tuple[host: Host, port: Port]

  ConnectionEventHandler* = proc(peer: enet.Peer)
  PacketEventHandler* = proc(peer: enet.Peer, channelId: uint8, packet: enet.Packet)
  
  Client* = object
    host: ptr enet.Host
    peers: seq[ptr enet.Peer]

    onConnect: ConnectionEventHandler
    onDisconnect: ConnectionEventHandler
    onReceive: PacketEventHandler

# ---- stringifiers ----
proc `$`*(address: enet.Address): string =
  $address.host & ":" & $address.port

proc `$`*(host: enet.Host): string =
  "Host: " & $host.address

proc `$`*(peer: enet.Peer): string =
  "Peer: " & $peer.address

proc `$`*(packet: ptr Packet): string =
  "Packet of size " & $packet.dataLength
    
# ---- converters ----
# proc getAddress(host: string, port: uint16): enet.Address =
#   discard enet.address_set_host(result.addr, host.cstring)
#   result.port = port


# ---- global ----
proc init*() =
  ## Init library
  if enet.initialize() != 0.cint:
    raise newException(LibraryError, "An error occurred during initialization")

proc deinit*() =
  ## Shutdown library
  enet.deinitialize()

# ---- server ----
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
  onConnect: ConnectionEventHandler = onConnect,
  onDisconnect: ConnectionEventHandler = onDisconnect,
  onReceive: PacketEventHandler = onReceive,
) =
  var
    addressPtr: ptr enet.Address = nil
  
  if port != 0:
    var address = enet.Address(host: enet.HOST_ANY, port: port)
    addressPtr = address.addr

  self.host = enet.host_create(
    addressPtr,
    numConnections.csize,
    numChannels.csize,
    inBandwidth.uint16,
    outBandwidth.uint16
  )
  if self.host == nil:
    raise newException(LibraryError, "An error occured while trying to init host")

  # set up handlers
  self.onConnect = onConnect
  self.onDisconnect = onDisconnect
  self.onReceive = onReceive

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
      let index = self.peers.find(event.peer)
      assert(index != -1)
      self.peers.del(index)
    else:
      discard

proc send*(self: Client, peer: enet.Peer, channelId: uint8, data: string, reliable = false, immediate = false) =
  var packet = enet.packet_create(
    data.cstring,
    (data.cstring.len + 1).csize,
    if reliable: enet.PACKET_FLAG_RELIABLE else: enet.PACKET_FLAG_UNRELIABLE,
  )
  discard enet.peer_send(peer.addr, channelId, packet)

  if immediate:
    enet.host_flush(self.host)

# ---- both ----
{.experimental.}
proc `=destroy`(self: var Client) =
  enet.host_destroy(self.host)

# proc createPacket(data: string, kind=enet.PACKET_FLAG_UNRELIABLE_FRAGMENT): ptr enet.Packet =
# var data = 
# result = enet.packet_create(data.addr, data.len.csize, kind)
