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
    entitiesMap*: Table[Entity, Entity]  # table for converting remote Entity to local one
    # TODO: exposing `entitiesMap` is not a good idea!


# ---- messages ----
type
  ConnectMessage* = object of Message
    ## Send this message to network system in order to connect to server.
    ## Example: (ref ConnectMessage)(address: ("localhost", "5555")).send(config.systems.network)
    address*: Address
  
messages.register(ConnectMessage)
method `$`*(self: ref ConnectMessage): string = &"{self[].type.name}: {self.address}"

# TODO: DisconnectMessage


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
  self.entitiesMap = initTable[Entity, Entity]()

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


# ---- handlers ----
method store*(self: ref NetworkSystem, message: ref Message) =
  ## Network system stores messages differently by default.
  ## While other systems store all incoming messages for futher processing, network system _sends_ all local messages without storing and processing them.
  ## All incoming non-local messages (from remote hosts) are stored and processed as usual.
  ## This behaviour may be disabled for any specific message kind. For example, we don't need to send QuitMessage over the network, so we store and process it (see defaults/handlers.nim).
  if message.isExternal:
    procCall ((ref System)self).store(message)  # save all external messages for further processing
  else:
    self.send(message)  # do not store and send all local incoming messages
    # TODO: recipient handling - to which peer is this message?
    # TODO: group and send bulk?

method process*(self: ref NetworkSystem, message: ref ConnectMessage) =
  ## When receiving ``ConnectMessage`` from any local system, try to connect to the address specified.
  if not message.isExternal:
    logging.debug &"Connecting to {message.address}"
    self.connect(message.address)

# TODO: process DisconnectMessage

method store*(self: ref NetworkSystem, message: ref QuitMessage) =
  ## By default network system sends all local incoming messages to remote peers. However, we don't need to send ``QuitMessage`` over the network, we only need to store it and then disconnect and shutdown when processing it.
  procCall ((ref System)self).store(message)

method process*(self: ref NetworkSystem, message: ref QuitMessage) =
  self.disconnect()
  logging.debug "Disconnected"

# TODO: send `CreateEntityMessage` and `DeleteEntityMessage` RELIABLE!

method process*(self: ref NetworkSystem, message: ref EntityMessage) =
  ## Every entity message requires converting remote Entity to local one.
  ## Call this in every method which processes `EntityMessage` subtypes.
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
