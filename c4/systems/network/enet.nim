import logging
import tables
import strformat
import streams
import "../../systems"
import "../../config"
import "../../core/entities"
import "../../core/messages"
import "../../presets/default/messages" as default_messages
import "../../wrappers/enet/enet"
import "../../wrappers/msgpack/msgpack"


type
  Host* = string
  Port* = uint16
  Address* = tuple[host: Host, port: Port]

  NetworkSystem* = object of System
    host: ptr enet.Host  # remember own host
    peers: Table[ptr enet.Peer, ref messages.Peer]  # table for converting internal enet.Peer into generic Peer
    entities: Table[Entity, Entity]  # table for converting remote Entity to local one


# ---- helpers ----
proc `$`*(address: enet.Address): string =
  const ipLength = "000.000.000.000".len
  var address = address

  result = newString(ipLength)
  if address_get_host_ip(address.addr, result, ipLength) != 0:
    raise newException(LibraryError, "Could not get printable address")

  result &= &":{$address.port}"

proc `$`*(host: enet.Host): string =
  $host.address

proc `$`*(peer: enet.Peer): string =
  $peer.address

proc `$`*(packet: ptr Packet): string =
  "Packet of size " & $packet.dataLength

proc toString(packet: enet.Packet): string =
  result = newString(packet.dataLength)
  copyMem(result.cstring, packet.data, packet.dataLength)
  
# ---- methods ----
method send*(
  self: ref NetworkSystem,
  message: ref Message,
  peer: ptr enet.Peer = nil,  # set nil to broadcast  # TODO: replace with ref messages.Peer
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

  logging.debug &"--> Network: sending {message} (packed as \"{data.stringify}\", len={data.len})"

  if peer == nil:  # broadcast
    enet.host_broadcast(self.host, channelId, packet)
  else:
    discard enet.peer_send(peer, channelId, packet)

  if immediate:
    enet.host_flush(self.host)

method store*(self: ref NetworkSystem, message: ref Message) =
  ## Network system stores messages differently by default.
  ## While other systems store all incoming messages for futher processing, network system _sends_ all local messages without storing and processing them.
  ## All incoming non-local messages (from remote hosts) are stored and processed as usual.
  ## This behaviour may be disabled for any specific message kind. For example, we don't need to send QuitMessage over the network, so we store and process it (see defaults/handlers.nim).
  if message.isExternal:
    procCall ((ref System)self).store(message)  # save all external messages for further processing
  else:
    self.send(message)  # do not store and send all incoming messages
    # TODO: recipient handling - to which peer is this message?
    # TODO: group and send bulk?
 
method init*(self: ref NetworkSystem) =
  # TODO: make these params configurable
  var
    numConnections = 32
    numChannels = 2
    inBandwidth = 0
    outBandwidth = 0

  if enet.initialize() != 0.cint:
    let err = "An error occurred during initialization"
    logging.fatal(err)
    raise newException(LibraryError, err)

  # set up address - nil for client, HOST_ANY+port for server
  var addressPtr: ptr enet.Address = nil
  if config.mode == server:
    var address = enet.Address(host: enet.HOST_ANY, port: config.settings.network.port)
    addressPtr = address.addr

  self.host = enet.host_create(addressPtr, numConnections.csize, numChannels.csize, inBandwidth.uint16, outBandwidth.uint16)
  if self.host == nil:
    raise newException(LibraryError, "An error occured while trying to init host. Maybe that port is already in use?")

  self.peers = initTable[ptr enet.Peer, ref messages.Peer]()

  procCall ((ref System)self).init()

method handle*(self: ref NetworkSystem, event: enet.Event) {.base.} =
  case event.`type`
  of EVENT_TYPE_CONNECT:
    self.peers[event.peer] = new(messages.Peer)
    logging.debug &"--- Connection established: {event.peer[]}"
  of EVENT_TYPE_RECEIVE:
    var message: ref Message
    event.packet[].toString().unpack(message)
    
    # include sender info into the message
    if self.peers.hasKey(event.peer):
      message.peer = self.peers[event.peer]
      logging.debug &"<-- Received {message} from peer {message.peer[]}"
      self.store(message)  # TODO: event.channelID data is missing in message
    else:
      logging.warn &"x<- Received message {message} from unregistered peer {event.peer[]}, discarding"

    enet.packet_destroy(event.packet)
  of EVENT_TYPE_DISCONNECT:
    logging.debug &"-x- Connection closed: {event.peer[]}"
    self.peers.del(event.peer)
    event.peer.peer_reset()
  else:
    discard

method connect*(self: ref NetworkSystem, address: Address, numChannels = 1) {.base.} =
  var enetAddress: enet.Address
  discard enet.address_set_host(enetAddress.addr, address.host.cstring)
  enetAddress.port = address.port

  if enet.host_connect(self.host, enetAddress.addr, numChannels.csize, 0.uint32) == nil:
    raise newException(LibraryError, "No available peers for initiating an ENet connection")

  # further connection success / failure is handled by handleConnect / handleDisconnect
  
method disconnect*(self: ref NetworkSystem, peer: ptr enet.Peer, force = false, timeout = 1000) {.base.} =
  if not force:
    enet.peer_disconnect(peer, 0)

    var event {.global.}: Event
    while enet.host_service(self.host, addr(event), timeout.uint32) != 0:
      self.handle(event)

  if not self.peers.hasKey(peer):  # if successfully disconnected from peer
    return

  if not force:
    logging.warn "Soft disconnection from {peer[]} failed"
  logging.debug &"-x- Force disconnected from {peer[]}"
  self.peers.del(peer)
  peer.peer_reset()

method disconnect*(self: ref NetworkSystem, force = false) {.base.} =
  for peer in self.peers.keys:
    self.disconnect(peer, force)

method update*(self: ref NetworkSystem, dt: float) =
  ## Check whether there is any network event and process if any
  var event {.global.}: enet.Event

  while enet.host_service(self.host, addr(event), 0.uint32) != 0:
    self.handle(event)
  
  procCall ((ref System)self).update(dt)

proc `=destroy`*(self: var NetworkSystem) =
  enet.host_destroy(self.host)
  enet.deinitialize()
