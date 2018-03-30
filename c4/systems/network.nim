from logging import debug, fatal
from strformat import `&`
from "../systems" import System, init, update
import "../core/messages"  # important! import everything from this module
import "../core/messages/builtins"
import "../wrappers/enet/enet"
import "../wrappers/msgpack/msgpack"
from streams import newStringStream, writeData, setPosition


# ---- types ----
type
  Host* = string
  Port* = uint16
  Address* = tuple[host: Host, port: Port]

  NetworkSystem* = object of System
    host: ptr enet.Host
    peers: seq[ptr enet.Peer]


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

proc toString(packet: enet.Packet): string =
  result = newString(packet.dataLength)
  copyMem(result.cstring, packet.data, packet.dataLength)
  # result.cstring[packet.dataLength] = '\0'
  
# ---- methods ----
method send*(
  self: ref NetworkSystem,
  message: ref Message,
  peer: ptr enet.Peer = nil,  # set nil to broadcast
  channelId:uint8 = 0,
  reliable = false,
  immediate = false
) {.base.} =
  var
    data: string = pack(message)
    packet = enet.packet_create(
      data.cstring,
      data.len.csize,  # do not read trailing \0
      if reliable: enet.PACKET_FLAG_RELIABLE else: enet.PACKET_FLAG_UNRELIABLE,
    )

  logging.debug(&"Network sending message: {message} (packed as {data.stringify} of len {data.len})")

  if peer == nil:  # broadcast
    enet.host_broadcast(self.host, channelId, packet)
  else:
    discard enet.peer_send(peer, channelId, packet)

  if immediate:
    enet.host_flush(self.host)

method process*(self: ref NetworkSystem, message: ref Message) =
  self.send(message)
 
method init*(
  self: ref NetworkSystem,
  port: Port = 0,
  numConnections = 32,
  numChannels = 2,
  inBandwidth = 0,
  outBandwidth = 0
) {.base.} =
  if enet.initialize() != 0.cint:
    let err = "An error occurred during initialization"
    logging.fatal(err)
    raise newException(LibraryError, err)

  # set up address
  var addressPtr: ptr enet.Address = nil
  if port != 0:
    var address = enet.Address(host: enet.HOST_ANY, port: port)
    addressPtr = address.addr

  self.host = enet.host_create(addressPtr, numConnections.csize, numChannels.csize, inBandwidth.uint16, outBandwidth.uint16)
  if self.host == nil:
    raise newException(LibraryError, "An error occured while trying to init host")

  self.peers = @[]

  procCall ((ref System)self).init()

method handleConnect*(self: ref NetworkSystem, peer: enet.Peer) {.base.} =
  discard

method handleDisconnect*(self: ref NetworkSystem, peer: enet.Peer) {.base.} =
  discard
 
method handleMessage*(self: ref NetworkSystem, message: ref Message, peer: enet.Peer, channelId: uint8) {.base.} =
  discard

method connect*(self: ref NetworkSystem, address: Address, numChannels = 1) {.base.} =
  var enetAddress: enet.Address
  discard enet.address_set_host(enetAddress.addr, address.host.cstring)
  enetAddress.port = address.port

  if enet.host_connect(self.host, enetAddress.addr, numChannels.csize, 0.uint32) == nil:
    raise newException(LibraryError, "No available peers for initiating an ENet connection")

  # further connection success / failure is handled by handleConnect / handleDisconnect

method disconnect*(self: ref NetworkSystem, peer: ptr enet.Peer, force = false) {.base.} =
  if not force:
    enet.peer_disconnect(peer, 0)
    # TODO
    # wait(3)
    # check that we are disconnected - peer not in peers
    # if yes - return

  enet.peer_reset(peer)
  self.peers.remove(peer)
  
# proc pollConnection*(self: var enet.Event, connection: Connection, timeout = 0) =
#   discard enet.host_service(connection.host, addr(self), timeout.uint32)

method update*(self: ref NetworkSystem, dt: float) =
  ## Check whether there is any network event and process if any
  var
    event: enet.Event
    message: ref Message

  while enet.host_service(self.host, addr(event), 0.uint32) != 0:
    # for each event type call corresponding handlers
    case event.`type`
      of EVENT_TYPE_CONNECT:
        self.peers.add(event.peer)
        logging.debug(&"Peer connected: {event.peer[]}")
        self.handleConnect(event.peer[])
      of EVENT_TYPE_RECEIVE:
        # TODO: the following code block is really ugly
        event.packet[].toString().unpack(message)
        logging.debug(&"Unpacked message {message} from peer {event.peer[]}")
        self.handleMessage(message, event.peer[], event.channelID)
        enet.packet_destroy(event.packet)
      of EVENT_TYPE_DISCONNECT:
        logging.debug(&"Peer disconnected: {event.peer[]}")
        self.handleDisconnect(event.peer[])
        self.peers.remove(event.peer)
      else:
        discard
  
  procCall ((ref System)self).update(dt)

{.experimental.}
method `=destroy`*(self: ref NetworkSystem) {.base.} =
  enet.host_destroy(self.host)
  enet.deinitialize()
