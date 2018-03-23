from logging import debug, fatal
from strformat import `&`
import "../wrappers/enet/enet"
from "../core/messages" import Message, QuitMessage, subscribe, `$`
import "../wrappers/msgpack/msgpack"


# ---- types ----
type
  Host* = string
  Port* = uint16
  Address* = tuple[host: Host, port: Port]

  NetworkSystem* = object {.inheritable.}
    host: ptr enet.Host
    peers: seq[ptr enet.Peer]


# ---- register messages ----
register(Message)
register(Message, QuitMessage)

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


# ---- methods ----
method storeMessage*(self: ref NetworkSystem, message: ref Message) {.base.} =
  logging.debug(&"Network got new message: {message}")

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

  messages.subscribe(proc (message: ref Message) = self.storeMessage(message))

method handleConnect*(self: ref NetworkSystem, peer: enet.Peer) {.base.} =
  logging.debug(&"Peer connected: {peer}")

method handleDisconnect*(self: ref NetworkSystem, peer: enet.Peer) {.base.} =
  logging.debug(&"Peer disconnected: {peer}")
 
method handlePacket*(self: ref NetworkSystem, peer: enet.Peer, channelId: uint8, packet: enet.Packet) {.base.} =
  logging.debug(&"Received packet {packet} from peer {peer}")
  

# ---- converters ----
# proc getAddress(host: string, port: uint16): enet.Address =
#   discard enet.address_set_host(result.addr, host.cstring)
#   result.port = port


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
  
method update*(self: ref NetworkSystem, dt: float) {.base.} =
  ## Check whether there is any network event and process if any
  var event: enet.Event

  while enet.host_service(self.host, addr(event), 0.uint32) != 0:
    # for each event type call corresponding handlers
    case event.`type`
      of EVENT_TYPE_CONNECT:
        self.peers.add(event.peer)
        self.handleConnect(event.peer[])
      of EVENT_TYPE_RECEIVE:
        self.handlePacket(event.peer[], event.channelID, event.packet[])
        enet.packet_destroy(event.packet)
      of EVENT_TYPE_DISCONNECT:
        self.handleDisconnect(event.peer[])
        self.peers.remove(event.peer)
      else:
        discard

method send*(
  self: ref NetworkSystem,
  peer: ptr enet.Peer = nil,  # set nil to broadcast
  channelId:uint8 = 0,
  data: string,
  reliable = false,
  immediate = false
) {.base.} =
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
method `=destroy`*(self: ref NetworkSystem) {.base.} =
  enet.host_destroy(self.host)
  enet.deinitialize()
