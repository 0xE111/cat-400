## Basic UDP networking system based on Enet library.
## It takes care of messages (de)serialization and establishing connection between client and server.

import logging
import tables
import strformat
import streams
import unittest
import os
import net
import sets
import sequtils

import ../../lib/enet/enet

import ../../namedthreads
import ../../entities
import ../../messages
import ../../utils/loop


type
  NetworkSystem* {.inheritable.} = object
    host*: ptr Host
    connectedPeers*: HashSet[ptr Peer]

  ClientNetworkSystem* = object of NetworkSystem
    entitiesMap: Table[Entity, Entity]  # table for converting remote Entity to local one

  ServerNetworkSystem* = object of NetworkSystem


# ---- messages ----
type
  NetworkMessage* = object of Message
    ## Every message contains a reference to a sender (Peer).
    ## Network system should populate the `peer` field when receiving Message from remote machine.
    peer*: ptr Peer  ## Multi-purpose field. \
    ## 1) When sending message to other machine, this field contains peer which represents recipient. Send to nil to broafcast.
    ## 2) When receiving message from other machine, this field contans peer which sent the message. Nil means that the message is local.

  ConnectMessage* = object of NetworkMessage
    ## Send this message to network system in order to connect to server.
    ## Example: ``(ref ConnectMessage)(address: ("localhost", "1234")).send("network")``
    host*: string
    port*: Port

  DisconnectMessage* = object of NetworkMessage
    ## Send this message to network system in order to disconnect from server.
    ##
    ## Example: ``new(DisconnectMessage).send("network")``

  ConnectionOpenedMessage* = object of NetworkMessage
    ## This message is sent to network system when new connection with remote peer is established.

  ConnectionClosedMessage* = object of NetworkMessage
    ## This message is sent to network system when connection with remote peer is closed.

# there's no sense to pack pointer to Peer, so it will be nil when packed/unpacked
proc pack_type*[ByteStream](stream: ByteStream, self: ptr Peer) =
  stream.pack(nil)

proc unpack_type*[ByteStream](stream: ByteStream, self: var ptr Peer) =
  self = nil
  # self = cast[ptr Peer](alloc(sizeof(Peer)))


NetworkMessage.register()

ConnectMessage.register()
DisconnectMessage.register()
ConnectionOpenedMessage.register()
ConnectionClosedMessage.register()


proc toString(packet: enet.Packet): string =
  result = newString(packet.dataLength)
  copyMem(result.cstring, packet.data, packet.dataLength)

proc getHostIp*(self: Address): string =
  const ipLen = "000.000.000.000".len
  result = newString(ipLen)
  if address_get_host_ip(self.unsafeAddr, result, ipLen.csize_t) != 0:
    raise newException(ValueError, "Could not get printable ip address")

proc getHost*(self: Address): string =
  const hostLen = 64
  result = newString(hostLen)
  if address_get_host(self.unsafeAddr, result, hostLen.csize_t) != 0:
    raise newException(ValueError, "Could not get printable hostname")

proc `$`*(self: Address): string =
  try:
    self.getHost()
  except ValueError:
    self.getHostIp()

proc `$`*(self: Packet): string =
  &"Packet of size {self.dataLength}"

proc `$`*(self: Peer): string =
  $self.address

# proc hash*(self: ref Peer): Hash =
#   result = self[].addr.hash
#   # result = !$result


# ---- methods ----

proc netSend*(self: NetworkSystem, message: ref Message, peer: ptr Peer = nil,
           channelId: uint8 = 0, reliable: bool = false, immediate: bool = false) =
  var
    data: string = message.msgpack()
    packet = enet.packet_create(
      data.cstring,
      data.len.csize_t,  # do not read trailing \0
      if reliable: enet.PACKET_FLAG_RELIABLE else: enet.PACKET_FLAG_UNRELIABLE,
    )

  let sendSign = if reliable: "==>" else: "-->"
  logging.debug &"{sendSign} Network: sending {$(message)} (packed as \"{data.stringify}\", len={data.len})"

  if peer.isNil:
    self.host.host_broadcast(channelId, packet)

  else:
    if enet.peer_send(peer, channelId, packet) != 0:
      logging.error &"Could not send {packet[]} to {peer[]}"
      return

  if immediate:
    self.host.host_flush()

proc init*(self: var NetworkSystem) =
  # TODO: make these params configurable
  const
    numConnections = 32
    numChannels = 1
    inBandwidth = 0
    outBandwidth = 0
    port = 11477'u16

  if enet.initialize() != 0:
    const err = "An error occurred during initialization"
    logging.fatal(err)
    raise newException(LibraryError, err)

  # set up address - nil for client, HOST_ANY+port for server
  var serverAddress = Address(host: HOST_ANY, port: port)

  self.host = host_create(if self of ServerNetworkSystem: serverAddress.addr else: nil, numConnections, numChannels, inBandwidth, outBandwidth)
  if self.host == nil:
    raise newException(LibraryError, &"An error occured while trying to init host. Maybe port {port} is already in use?")

  logging.info &"Initialized network system on port {port}"

proc connect*(self: var NetworkSystem, host: string, port: Port, numChannels = 1) =
  var address: Address
  discard address_set_host(address.addr, host)
  address.port = port.uint16

  if self.host.host_connect(address.addr, numChannels.csize_t, 0.uint32).isNil:
    raise newException(LibraryError, "Could not establish connection")

  # further connection success / failure is handled by ``handle`` method

proc disconnect*(self: var NetworkSystem, peer: ptr Peer) {.gcsafe.} =
  # if not force:
  #   peer.peer_disconnect(0)

  #   var event: Event
  #   while self.host.host_service(event.addr, timeout.uint32) != 0:
  #     self.handle(event)

  # if peer notin self.connectedPeers:  # if successfully disconnected from peer
  #   return

  # if not force:
  #   logging.warn &"Soft disconnection from {peer[]} failed"

  logging.debug &"-x- Force disconnected from {peer[]}"
  self.connectedPeers.excl(peer)
  peer.peer_reset()

proc disconnect*(self: var NetworkSystem) =
  for peer in self.connectedPeers:
    self.disconnect(peer)

proc handle*(self: var NetworkSystem, event: Event) =
  ## Handles Enet events and updates ``peersMap``.
  ##
  ## - EVENT_TYPE_CONNECT: If peer with this address is already connected, then first disconnects this peer and sends ``ConnectionClosedMessage`` to self,  then sends ``ConnectionOpenedMessage`` to self;`.
  ## - EVENT_TYPE_DISCONNECT: Sends ``ConnectionClosedMessage`` to self;
  ## - EVENT_TYPE_RECEIVE: Unpacks message, populates ``sender`` field with ``messages.Peer`` instance, and stores the message.

  case event.`type`
    of EVENT_TYPE_CONNECT:
      # We need to check whether new peer is already connected. If yes then we just close previous connection and open a new one.

      # first, disconnect peer with same address as newly connected one
      for peer in toSeq(self.connectedPeers).filterIt(it.address == event.peer.address):
        logging.debug &"-x- Disconnecting existing peer {peer[]}"
        self.disconnect(peer)
        self.connectedPeers.excl(peer)
        (ref ConnectionClosedMessage)(peer: peer).send()

      # Now, send ``ConnectionOpenedMessage`` for newly created connection
      self.connectedPeers.incl(event.peer)
      (ref ConnectionOpenedMessage)(peer: event.peer).send()
      logging.info &"--- Connection established: {event.peer[]}"
      logging.debug &"Current connections: {toSeq(self.connectedPeers).mapIt(it[])}"

    of EVENT_TYPE_RECEIVE:
      var message: ref Message

      try:
        message = event.packet[].toString().msgunpack()

      except Exception as exc:
        # do not fail if received malformed message
        logging.error &"Could not unpack packet from {event.peer[]}: {exc.msg}"
        event.packet.packet_destroy()
        return

      if event.peer notin self.connectedPeers:
        logging.warn &"x<- Received {message} from unregistered peer {event.peer[]}, discarding"
        event.packet.packet_destroy()
        return

      if message of ref NetworkMessage:
        # include sender info into the message
        ((ref NetworkMessage) message).peer = event.peer

      logging.debug &"<-- Received {message} from peer {event.peer[]}"
      message.send()  # TODO: event.channelID data is missing in message

      event.packet.packet_destroy()

    of EVENT_TYPE_DISCONNECT:
      if event.peer notin self.connectedPeers:
        logging.warn &"Disconnecting peer {event.peer[]} not in connected peers set"

      else:
        logging.debug &"-x- Disconnecting existing peer {event.peer[]}"
        self.connectedPeers.excl(event.peer)
        (ref ConnectionClosedMessage)(peer: event.peer).send()

      event.peer.peer_reset()
      logging.debug &"-x- Connection closed: {event.peer[]}"

    else:
      discard

proc poll*(self: var NetworkSystem) =
  ## Check for new events and send them to itself
  var event: Event

  while true:  # TODO: maybe add limit to number of processed events
    let status = self.host.host_service(event.addr, 0.uint32)
    if status > 0:
      self.handle(event)
    elif status == 0:
      break
    else:
      logging.error &"Error while polling for new event"

proc dispose*(self: var NetworkSystem) =
  ## Destroy current host and deinitialize enet.
  self.host.host_destroy()
  enet.deinitialize()

method process*(self: var NetworkSystem, message: ref Message) {.base.} =
  logging.error &"No rule how to process {message}, discarding"


# ---- handlers ----
# method store*(self: ref NetworkSystem, message: ref Message) =
#   ## Network system should send outgoing messages as soon as possible. If we store outgoing messages as usual, they will be processed only after all network i/o done (see ``NetworkSystem.update`` method). Thus we will lose exactly one loop cycle before actually sending the message. To avoid this case, we don't store and process any outgoing messages. Instead, we instantly request enet to send them. When ``NetworkSystem`` is updated, it sends all outgoing messages, receives new ones and then processes all stored messages.
#   ##
#   ## Sometimes ``NetworkSystem`` may need to store and process message instead of sending it. For example, ``NetworkSystem`` receives ``SystemReadyMessage`` when all enet internals are initialized. This message should be processed, not sent over the network. To achieve this, we define custom ``store`` method which stores the message (``procCall self.as(ref System).store(message)``).
#   ##
#   ## Security note: all external messages from other peers are discarded by default. This prevents hackers from sending control messages (like ``ConnectMessage``) to remote peers. All network protection should be done inside ``store`` methods, thus ``process`` method receives only trusted messages.

#   # TODO: is there a better way to control in/out message restrictions?
#   if message.isLocal:
    # let recipient = message.recipient
    # message.recipient = nil  # do not send recipient over network
    # self.send(message, recipient)
    # # TODO: group and send bulk?

#   else:
#     logging.warn &"Dropped {$(message)}: external message without specific handler"


# method store*(self: ref ClientNetworkSystem, message: ref ConnectMessage) =
#   ## ``ConnectMessage`` may be sent only to client's network system in order to connect to server.
#   if message.isLocal:
#     procCall self.as(ref System).store(message)  # store message for further processing

#   else:
#     procCall self.store(message.as(ref Message))  # drop remote message with warning


# # method process*(self: var NetworkSystem, message: ref Message) {.base.} =
# #   if message.isLocal:
# #     let recipient = message.recipient
# #     message.recipient = nil  # do not send recipient over network
# #     self.send(message, recipient, reliable=message.isReliable)
# #     # TODO: group and send bulk?

# #   else:
# #     logging.warn &"No rule for processing {message}"


# method process*(self: var ClientNetworkSystem, message: ref ConnectMessage) =
#   ## When receiving ``ConnectMessage`` from any local system, try to connect to the address specified.
#   ##
#   ## As a most common case, peer may connect to only one another peer (client connects to only one server).Thus all existing connections will be closed before establishing new one. However, if it's not your case and you want to connect to multiple servers simultaneously, you can dismiss this restriction by overriding this method.
#   assert message.isLocal

#   logging.debug &"Disconnecting"
#   self.disconnect()

#   logging.debug &"Connecting to {$(message.address)}"
#   self.connect(message.address)


# # method store*(self: ref ClientNetworkSystem, message: ref DisconnectMessage) =
# #   ## ``DisconnectMessage`` may be sent only to client's network system in order to disconnect from server.
# #   if message.isLocal:
# #     procCall self.as(ref System).store(message)  # store message for further processing

# #   else:
# #     procCall self.store(message.as(ref Message))  # drop remote message with warning


# method process*(self: var ClientNetworkSystem, message: ref DisconnectMessage) =
#   ## When receiving ``DisconnectMessage`` from any local system, close all connections.
#   assert message.isLocal

#   logging.debug "Disconnecting"
#   self.disconnect()


# # method store*(self: ref NetworkSystem, message: ref ConnectionOpenedMessage) =
# #   ## Don't send this message over the network, store and process it instead.
# #   if message.isLocal:
# #     procCall self.as(ref System).store(message)  # store message for further processing

# #   else:
# #     procCall self.store(message.as(ref Message))  # drop remote message with warning


# # method store*(self: ref NetworkSystem, message: ref ConnectionClosedMessage) =
# #   ## Don't send this message over the network, store and process it instead.
# #   if message.isLocal:
# #     procCall self.as(ref System).store(message)  # store message for further processing

# #   else:
# #     procCall self.store(message.as(ref Message))  # drop remote message with warning


# method process*(self: var ClientNetworkSystem, message: ref ConnectionClosedMessage) =
#   ## Remove all entity mappings when client disconnects from external peer.
#   assert message.isLocal
#   self.entitiesMap.clear()


# # method process*(self: ServerNetworkSystem, message: ref SystemReadyMessage) =
# #   ## Print info message
# #   assert message.isLocal

# #   logging.info &"Server listening at localhost:{self.port}"


# # method process*(self: NetworkSystem, message: ref SystemQuitMessage) =
# #   ## Disconnect from all peers.
# #   assert message.isLocal

# #   self.disconnect()
# #   logging.debug "Disconnected"


# method process*(self: var ClientNetworkSystem, message: ref EntityMessage) =
#   ## Every entity message requires converting remote Entity to local one. Call this in every method which processes ``EntityMessage`` subtypes.
#   assert(not message.isLocal)

#   # TODO: When client just connected, it may receive entities messages _before_ those entities were actualy created, thus producing this warning. State management system would fix this.
#   if not self.entitiesMap.hasKey(message.entity):
#     logging.warn &"No local entity found for remote entity {message.entity} in message {$(message)}"
#     return

#   let externalEntity = message.entity
#   message.entity = self.entitiesMap[externalEntity]
#   logging.debug &"Mapped entity: (external) {externalEntity} -> {message.entity} (local)"


# method process*(self: var ClientNetworkSystem, message: ref CreateEntityMessage) =
#   ## When client's network system receives this message, it creates an ``Entity`` and updates remote-local entity conversion table.
#   assert (not message.isLocal)
#   assert(not self.entitiesMap.hasKey(message.entity), &"Local entity already exists for this remote entity: {message.entity}")

#   let entity = newEntity()
#   self.entitiesMap[message.entity] = entity
#   logging.debug &"Created new mapping: {message.entity} -> {entity}"

#   procCall self.process((ref EntityMessage)message)  # map entity


# method process*(self: var ClientNetworkSystem, message: ref DeleteEntityMessage) =
#   ## When client's network system receives this message, it removes the entity and updates remote-local entity conversion table.
#   assert (not message.isLocal)
#   assert(self.entitiesMap.hasKey(message.entity), &"No local entity found for this remote entity: {message.entity}")

#   let localEntity = self.entitiesMap[message.entity]
#   self.entitiesMap.del(message.entity)
#   localEntity.delete()
#   logging.debug &"Client deleted entity {localEntity}"


proc run*(self: var NetworkSystem) =
  self.init()

  loop(frequency=30) do:
    self.poll()

    while true:
      let message = tryRecv()
      if message.isNil:
        break

      self.process(message)
  do:
    discard

  self.dispose()


when isMainModule:
  method getPeer(self: ref Message): ptr Peer {.base.} = raise newException(ValueError, "Getting Peer of base Message type")
  method getPeer(self: ref NetworkMessage): ptr Peer = self.peer

  suite "System tests":
    test "Packing NetworkMessage":
      var message: ref Message

      let peer = cast[ptr Peer](alloc0(sizeof(Peer)))  # some random peer
      message = (ref NetworkMessage)(peer: peer)

      assert not message.getPeer.isNil
      let packed = message.msgpack()
      echo &"Packed NetworkMessage as '{packed.stringify()}'"

      # var unpacked = packed.msgunpack()
      message = packed.msgunpack()
      assert message.getPeer.isNil

    test "Running inside thread":
      spawn("thread") do:
        var system = ClientNetworkSystem()
        system.run()

      sleep 1000
