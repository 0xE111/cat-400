## Basic UDP networking system based on Enet library.
## It takes care of messages (de)serialization and establishing connection between client and server.

import logging
import tables
import strformat
import streams
import typetraits

import "../../systems"
import "../../config"
import "../../core/entities"
import "../../core/messages"
import "../../wrappers/enet/enet"
import "../../wrappers/msgpack/msgpack"
import "../../utils/stringify"


type
  Host* = string
  Port* = uint16
  Address* = tuple[host: Host, port: Port]

  NetworkSystem* = object of System
    host: ptr enet.Host  # remember own host
    peers: Table[ptr enet.Peer, ref messages.Peer]  # table for converting internal enet.Peer into generic Peer
    entitiesMap: Table[Entity, Entity]  # table for converting remote Entity to local one


# ---- helpers ----
proc `$`*(self: Address): string =
  &"{self.host}:{self.port}"

proc getHost*(self: enet.Address): string =
  const ipLength = "000.000.000.000".len

  result = newString(ipLength)
  if address_get_host_ip(self.unsafeAddr, result, ipLength) != 0:
    raise newException(LibraryError, "Could not get printable address")

proc `$`*(self: enet.Address): string =
  result = &"{self.getHost}:{self.port}"

proc `$`*(self: enet.Host): string =
  $self.address

proc `$`*(self: enet.Peer): string =
  $self.address

proc `$`*(self: ptr Packet): string =
  "Packet of size " & $self.dataLength

proc toString(packet: enet.Packet): string =
  result = newString(packet.dataLength)
  copyMem(result.cstring, packet.data, packet.dataLength)

# ---- messages ----
type
  ConnectMessage* = object of Message
    ## Send this message to network system in order to connect to server.
    ##
    ## Example: ``(ref ConnectMessage)(address: ("localhost", "1234")).send(config.systems.network)``
    ##
    ## The server's network system will also receive this message after successful connection of client.
    address*: Address  ## Address to connect to (server's address)

  DisconnectMessage* = object of Message
    ## Send this message to network system in order to disconnect from server.
    ##
    ## Example: ``new(DisconnectMessage).send(config.systems.network)``
    ##
    ## The server's network system will also receive this message after successful disconnection of client.

  PrivateMessage* = object of Message
    ## Base type for sending message to only specific ``Peer``. Network system will send this message only to one Peer instead of broadcasting it.
    recipient*: ref messages.Peer
  

messages.register(ConnectMessage)
method `$`*(self: ref ConnectMessage): string = &"{self[].type.name}: {self.address}"

messages.register(DisconnectMessage)
strMethod(DisconnectMessage)

# ---- methods ----
method send*(
  self: ref NetworkSystem,
  message: ref Message,
  peer: ref messages.Peer = nil,  # set nil to broadcast
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
    # reverse Table lookup
    for enetPeer, msgsPeer in self.peers.pairs():
      if msgsPeer == peer:
        discard enet.peer_send(enetPeer, channelId, packet)
        break
    
  if immediate:
    enet.host_flush(self.host)
 
method init*(self: ref NetworkSystem) =
  # TODO: make these params configurable
  var
    numConnections = 32
    numChannels = 1
    inBandwidth = 0
    outBandwidth = 0

  if enet.initialize() != 0:
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
  self.entitiesMap = initTable[Entity, Entity]()

  procCall ((ref System)self).init()

# forward declaration, needed for ``handle`` method
method disconnect*(self: ref NetworkSystem, peer: ptr enet.Peer, force = false, timeout = 1000) {.base.}

method handle*(self: ref NetworkSystem, event: enet.Event) {.base.} =
  case event.`type`
  of EVENT_TYPE_CONNECT:
    # We need to check whether new peer is already connected. If yes then we just close previous connection and open a new one.
    
    # First, disconnect peers with same address as newly connected one
    var peersToDelete: seq[ptr enet.Peer] = @[]
    for peer in self.peers.keys():
      if peer.address == event.peer.address:
        logging.debug &"-x- Closing existing connection: {event.peer[]}"
        self.disconnect(peer)
        peersToDelete.add(peer)
    
    # Second, for each disconnected peer send a ``DisconnectMessage`` to local network system and
    # delete this peer from peer mapping table.
    for peer in peersToDelete:
      (ref DisconnectMessage)(peer: self.peers[peer]).send(self)
      self.peers.del(peer)

    # Now, send ``ConnectMessage`` for newly created connection
    let newPeer = new(messages.Peer)
    self.peers[event.peer] = newPeer
    (ref ConnectMessage)(peer: newPeer).send(self)
    logging.debug &"--- Connection established: {event.peer[]}"
    logging.debug &"Current # of connections: {self.peers.len}"
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
    (ref DisconnectMessage)(peer: self.peers[event.peer]).send(self)
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


# ---- handlers ----
method store*(self: ref NetworkSystem, message: ref Message) =
  ## Network system stores messages differently by default.
  ## While other systems store all incoming messages for futher processing, network system sends all local messages without storing and processing them.
  ## All incoming non-local messages (from remote hosts) are stored and processed as usual.
  ## This behaviour may be disabled for any specific message kind. For example, we don't need to send QuitMessage over the network, so we store and process it.
  if message.isExternal:
    procCall ((ref System)self).store(message)  # save all external messages for further processing
  else:
    self.send(message)  # do not store and send all local incoming messages
    # TODO: group and send bulk?
  
method store*(self: ref NetworkSystem, message: ref PrivateMessage) =
  if message.isExternal:
    procCall ((ref System)self).store(message)
  else:
    let recipient = message.recipient
    message.recipient = nil  # do not send recipient over network
    self.send(message, recipient)

method store(self: ref NetworkSystem, message: ref ConnectMessage) =
  ## By default network system sends all local incoming messages.
  ## However, we want to store and process ``ConnectMessage``.
  procCall ((ref System)self).store(message)

method process*(self: ref NetworkSystem, message: ref ConnectMessage) =
  ## When receiving ``ConnectMessage`` from any local system, try to connect to the address specified. Only one connection is allowed, so any previous connections will be closed.
  if not message.isExternal:
    # Disconnect before new connection. As a most common case, peer may connect to only one another peer (client connects to only one server). However, if it's not your case, and you want to connect to multiple servers simultaneously, you can dismiss this restriction by overriding this method.
    self.disconnect()

    logging.debug &"Connecting to {message.address}"
    self.connect(message.address)

method store(self: ref NetworkSystem, message: ref DisconnectMessage) =
  ## By default network system sends all local incoming messages.
  ## However, we want to store and process ``DisconnectMessage``.
  procCall ((ref System)self).store(message)

method process*(self: ref NetworkSystem, message: ref DisconnectMessage) =
  ## Disconnect when receiving ``DisconnectMessage``
  if not message.isExternal:
    logging.debug "Disconnecting"
    self.disconnect()

# TODO: maybe there's a way to combine two following methods into one?
method store*(self: ref NetworkSystem, message: ref SystemQuitMessage) =
  ## By default network system sends all local incoming messages to remote peers. However, we don't need to send ``QuitMessage`` over the network, we only need to store it and then disconnect and shutdown when processing it.
  procCall ((ref System)self).store(message)

method store*(self: ref NetworkSystem, message: ref SystemReadyMessage) =
  ## Same for ``SystemReadyMessage`` - there's no need to send this message over the network, so we just store and process it.
  procCall ((ref System)self).store(message)

method process*(self: ref NetworkSystem, message: ref SystemReadyMessage) =
  logging.info &"Server listening at localhost:{config.settings.network.port}"

method process*(self: ref NetworkSystem, message: ref SystemQuitMessage) =
  self.disconnect()
  logging.debug "Disconnected"

# TODO: send `CreateEntityMessage` and `DeleteEntityMessage` RELIABLE!

method process*(self: ref NetworkSystem, message: ref EntityMessage) =
  ## Every entity message requires converting remote Entity to local one.
  ## Call this in every method which processes ``EntityMessage`` subtypes.
  assert(message.isExternal, &"Message is not external: {message}")
  assert(self.entitiesMap.hasKey(message.entity), &"No local entity found for this remote entity: {message.entity}")
  message.entity = self.entitiesMap[message.entity]
  logging.debug "Mapped external Entity to local one"

method process*(self: ref NetworkSystem, message: ref CreateEntityMessage) =
  assert(not self.entitiesMap.hasKey(message.entity), &"Local entity already exists for this remote entity: {message.entity}")
  let entity = newEntity()
  self.entitiesMap[message.entity] = entity

method process*(self: ref NetworkSystem, message: ref DeleteEntityMessage) =
  assert(self.entitiesMap.hasKey(message.entity), &"No local entity found for this remote entity: {message.entity}")
  let entity = self.entitiesMap[message.entity]
  self.entitiesMap.del(message.entity)
  entity.delete()
