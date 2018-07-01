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
    peersMap: Table[ptr enet.Peer, ref messages.Peer]  # table for converting enet.Peer into messages.Peer
    entitiesMap: Table[Entity, Entity]  # table for converting remote Entity to local one
    # TODO: works only on client side, does server need ``entitiesMap`` at all? (probably no, but who knows)


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

    address*: Address  # Address to connect to (server's address)

  DisconnectMessage* = object of Message
    ## Send this message to network system in order to disconnect from server.
    ##
    ## Example: ``new(DisconnectMessage).send(config.systems.network)``

  ConnectionOpenedMessage* = object of Message
    ## This message is sent to network system when new connection with remote peer is established.
    peer*: ref messages.Peer

  ConnectionClosedMessage* = object of Message
    ## This message is sent to network system when connection with remote peer is closed.
    peer*: ref messages.Peer
  

messages.register(ConnectMessage)
method `$`*(self: ref ConnectMessage): string = &"{self[].type.name}: {self.address}"

messages.register(DisconnectMessage)
strMethod(DisconnectMessage)

messages.register(ConnectionOpenedMessage)
method `$`*(self: ref ConnectionOpenedMessage): string = &"{self[].type.name}: {self.peer[]}"

messages.register(ConnectionClosedMessage)
method `$`*(self: ref ConnectionClosedMessage): string = &"{self[].type.name}: {self.peer[]}"


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
    for enetPeer, msgsPeer in self.peersMap.pairs():
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
  if mode == server:
    var address = enet.Address(host: enet.HOST_ANY, port: config.settings.network.port)
    addressPtr = address.addr

  self.host = enet.host_create(addressPtr, numConnections.csize, numChannels.csize, inBandwidth.uint16, outBandwidth.uint16)
  if self.host == nil:
    raise newException(LibraryError, "An error occured while trying to init host. Maybe that port is already in use?")

  self.peersMap = initTable[ptr enet.Peer, ref messages.Peer]()
  self.entitiesMap = initTable[Entity, Entity]()

  procCall ((ref System)self).init()

# forward declaration, needed for ``handle`` method
method disconnect*(self: ref NetworkSystem, peer: ptr enet.Peer, force = false, timeout = 1000) {.base.}

method handle*(self: ref NetworkSystem, event: enet.Event) {.base.} =
  ## Handles Enet events and updates ``peersMap``.
  ##
  ## - EVENT_TYPE_CONNECT: If peer with this address is already connected, then first disconnects this peer and sends ``ConnectionClosedMessage`` to self,  then sends ``ConnectionOpenedMessage`` to self;`.
  ## - EVENT_TYPE_DISCONNECT: Sends ``ConnectionClosedMessage`` to self;
  ## - EVENT_TYPE_RECEIVE: Unpacks message, populates ``sender`` field with ``messages.Peer`` instance, and stores the message.

  case event.`type`
    of EVENT_TYPE_CONNECT:
      # We need to check whether new peer is already connected. If yes then we just close previous connection and open a new one.
      
      # First, disconnect peers with same address as newly connected one
      var peersToDelete: seq[ptr enet.Peer] = @[]
      for peer in self.peersMap.keys():
        if peer.address == event.peer.address:
          logging.debug &"-x- Closing existing connection: {event.peer[]}"
          self.disconnect(peer)
          peersToDelete.add(peer)
      
      # Second, for each disconnected peer send a ``DisconnectMessage`` to local network system and
      # delete this peer from peer mapping table.
      for peer in peersToDelete:
        (ref ConnectionClosedMessage)(peer: self.peersMap[peer]).send(self)
        self.peersMap.del(peer)

      # Now, send ``ConnectionOpenedMessage`` for newly created connection
      let newPeer = new(messages.Peer)
      self.peersMap[event.peer] = newPeer
      (ref ConnectionOpenedMessage)(peer: newPeer).send(self)
      logging.debug &"--- Connection established: {event.peer[]}"
      logging.debug &"Current # of connections: {self.peersMap.len}"
    of EVENT_TYPE_RECEIVE:
      var message: ref Message
      event.packet[].toString().unpack(message)

      # TODO: check that message's runtime type is not Message (which means that message was not registered)
      
      # include sender info into the message
      if self.peersMap.hasKey(event.peer):
        message.sender = self.peersMap[event.peer]
        logging.debug &"<-- Received {message} from peer {message.sender[]}"
        self.store(message)  # TODO: event.channelID data is missing in message
      else:
        logging.warn &"x<- Received message {message} from unregistered peer {event.peer[]}, discarding"

      enet.packet_destroy(event.packet)
    of EVENT_TYPE_DISCONNECT:
      logging.debug &"-x- Connection closed: {event.peer[]}"
      (ref ConnectionClosedMessage)(peer: self.peersMap[event.peer]).send(self)
      self.peersMap.del(event.peer)
      event.peer.peer_reset()
    else:
      discard

method connect*(self: ref NetworkSystem, address: Address, numChannels = 1) {.base.} =
  var enetAddress: enet.Address
  discard enet.address_set_host(enetAddress.addr, address.host.cstring)
  enetAddress.port = address.port

  if enet.host_connect(self.host, enetAddress.addr, numChannels.csize, 0.uint32) == nil:
    raise newException(LibraryError, "No available peers for initiating an ENet connection")

  # further connection success / failure is handled by ``handle`` method
  
method disconnect*(self: ref NetworkSystem, peer: ptr enet.Peer, force = false, timeout = 1000) {.base.} =
  if not force:
    enet.peer_disconnect(peer, 0)

    var event {.global.}: Event
    while enet.host_service(self.host, addr(event), timeout.uint32) != 0:
      self.handle(event)

  if not self.peersMap.hasKey(peer):  # if successfully disconnected from peer
    return

  if not force:
    logging.warn "Soft disconnection from {peer[]} failed"
  logging.debug &"-x- Force disconnected from {peer[]}"
  self.peersMap.del(peer)
  peer.peer_reset()

method disconnect*(self: ref NetworkSystem, force = false) {.base.} =
  for peer in self.peersMap.keys:
    self.disconnect(peer, force)

method update*(self: ref NetworkSystem, dt: float) =
  ## Network system is updated in 2 steps:
  ##
  ## - poll the connection: receive and store incoming messages and send outgoing messages;
  ## - process all stored messages by calling ``process`` method on each message.

  var event {.global.}: enet.Event

  while enet.host_service(self.host, addr(event), 0.uint32) != 0:
    self.handle(event)
  
  procCall ((ref System)self).update(dt)

proc `=destroy`*(self: var NetworkSystem) =
  ## Destroy current host and deinitialize enet.
  enet.host_destroy(self.host)
  enet.deinitialize()


# ---- handlers ----
method store*(self: ref NetworkSystem, message: ref Message) =
  ## Network system should send outgoing messages as soon as possible. If we store outgoing messages as usual, they will be processed only after all network i/o done (see ``NetworkSystem.update`` method). Thus we will lose exactly one loop cycle before actually sending the message. To avoid this case, we don't store and process any outgoing messages. Instead, we instantly request enet to send them. When ``NetworkSystem`` is updated, it sends all outgoing messages, receives new ones and then processes all stored messages.
  ##
  ## Sometimes ``NetworkSystem`` may need to store and process message instead of sending it. For example, ``NetworkSystem`` receives ``SystemReadyMessage`` when all enet internals are initialized. This message should be processed, not sent over the network. To achieve this, we define custom ``store`` method which stores the message (``procCall (ref System)self).store(message)``).
  ##
  ## Security note: all external messages from other peers are discarded by default. This prevents hackers from sending control messages (like ``ConnectMessage``) to remote peers. All network protection should be done inside ``store`` methods, thus ``process`` method receives only trusted messages.

  # TODO: is there a better way to control in/out message restrictions?
  
  if message.isLocal:
    let recipient = message.recipient
    message.recipient = nil  # do not send recipient over network
    self.send(message, recipient)
    # TODO: group and send bulk?
  
  else:
    logging.warn &"Dropped {message}: external message"


method store*(self: ref NetworkSystem, message: ref ConnectMessage) =
  ## ``ConnectMessage`` may be sent only to client's network system in order to connect to server.
  
  # don't send this message over the network, store and process it instead.
  if message.isLocal and mode == client:
    procCall ((ref System)self).store(message)

  elif not message.isLocal:
    procCall self.store((ref Message)message)  # drop remote message with warning
  
  elif mode == server:
    logging.warn &"Dropped {message}: should be sent on client (currently {mode})"

method process*(self: ref NetworkSystem, message: ref ConnectMessage) =
  ## When receiving ``ConnectMessage`` from any local system, try to connect to the address specified.
  ##
  ## As a most common case, peer may connect to only one another peer (client connects to only one server).Thus all existing connections will be closed before establishing new one. However, if it's not your case and you want to connect to multiple servers simultaneously, you can dismiss this restriction by overriding this method.

  assert message.isLocal
  assert mode == client

  self.disconnect()

  logging.debug &"Connecting to {message.address}"
  self.connect(message.address)


method store*(self: ref NetworkSystem, message: ref DisconnectMessage) =
  ## ``DisconnectMessage`` may be sent only to client's network system in order to disconnect from server.

  if message.isLocal and mode == client:
    procCall ((ref System)self).store(message)
  
  elif not message.isLocal:
    procCall self.store((ref Message)message)  # drop remote message with warning
  
  elif mode != client:
    logging.warn &"Dropped {message}: should be sent on client (currently {mode})"

method process*(self: ref NetworkSystem, message: ref DisconnectMessage) =
  ## When receiving ``DisconnectMessage`` from any local system, close all connections.

  assert message.isLocal
  assert mode == client

  logging.debug "Disconnecting"
  self.disconnect()


method store*(self: ref NetworkSystem, message: ref ConnectionOpenedMessage) =
  ## Don't send this message over the network, store and process it instead.

  if message.isLocal:
    procCall ((ref System)self).store(message)
  
  else:
    procCall self.store((ref Message)message)  # drop remote message with warning


method store*(self: ref NetworkSystem, message: ref ConnectionClosedMessage) =
  ## Don't send this message over the network, store and process it instead.

  if message.isLocal:
    procCall ((ref System)self).store(message)
  
  else:
    procCall self.store((ref Message)message)  # drop remote message with warning

method process*(self: ref NetworkSystem, message: ref ConnectionClosedMessage) =
  ## Remove all entity mappings when client disconnects from external peer.
  assert message.isLocal

  if mode == client:
    self.entitiesMap = initTable[Entity, Entity]()


method store*(self: ref NetworkSystem, message: ref SystemReadyMessage) =
  ## Don't send this message over the network, store and process it instead.

  if message.isLocal:
    procCall ((ref System)self).store(message)

  else:
    procCall self.store((ref Message)message)  # drop remote message with warning

method process*(self: ref NetworkSystem, message: ref SystemReadyMessage) =
  ## Print info message.

  assert message.isLocal

  if mode == server:
    logging.info &"Server listening at localhost:{config.settings.network.port}"


method store*(self: ref NetworkSystem, message: ref SystemQuitMessage) =
  ## Don't send this message over the network, store and process it instead.

  if message.isLocal:
    procCall ((ref System)self).store(message)
  
  else:
    procCall self.store((ref Message)message)  # drop remote message with warning

method process*(self: ref NetworkSystem, message: ref SystemQuitMessage) =
  ## Disconnect from all peers.

  assert message.isLocal

  self.disconnect()
  logging.debug "Disconnected"


method store*(self: ref NetworkSystem, message: ref EntityMessage) =
  ## Server only sends local ``EntityMessage``, client only receives remote ``EntityMessage``.
  ##
  ## Entity messages are sent reliably.

  if (mode == server and message.isLocal):
    # send RELIABLY over network
    let recipient = message.recipient
    message.recipient = nil  # do not send recipient over network
    self.send(message, recipient, reliable=true)
  
  elif (mode == client and not message.isLocal):
    procCall ((ref System)self).store(message)  # store this message

  else:
    logging.warn &"Dropped {message}: should be local server message or remote client one (currently {mode}, local={message.isLocal})"

method process*(self: ref NetworkSystem, message: ref EntityMessage) =
  ## Every entity message requires converting remote Entity to local one. Call this in every method which processes ``EntityMessage`` subtypes.

  assert mode == client
  assert (not message.isLocal)
  assert(self.entitiesMap.hasKey(message.entity), &"No local entity found for remote entity {message.entity}")

  message.entity = self.entitiesMap[message.entity]
  logging.debug &"External Entity is mapped to local {message.entity}"

method process*(self: ref NetworkSystem, message: ref CreateEntityMessage) =
  ## When client's network system receives this message, it creates an ``Entity`` and updates remote-local entity conversion table.

  assert mode == client
  assert (not message.isLocal)
  assert(not self.entitiesMap.hasKey(message.entity), &"Local entity already exists for this remote entity: {message.entity}")

  let entity = newEntity()
  logging.debug &"Client created new entity {entity}"
  self.entitiesMap[message.entity] = entity

  procCall self.process((ref EntityMessage)message)  # map entity

method process*(self: ref NetworkSystem, message: ref DeleteEntityMessage) =
  ## When client's network system receives this message, it removes the entity and updates remote-local entity conversion table.

  assert mode == client
  assert (not message.isLocal)
  assert(self.entitiesMap.hasKey(message.entity), &"No local entity found for this remote entity: {message.entity}")

  let localEntity = self.entitiesMap[message.entity]
  self.entitiesMap.del(message.entity)
  localEntity.delete()
  logging.debug &"Client deleted entity {localEntity}"
