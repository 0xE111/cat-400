## Basic UDP networking system based on Enet library.
## It takes care of messages (de)serialization and establishing connection between client and server.

import logging
import tables
import strformat
import os
import net
import sets
import sequtils
import typetraits
when isMainModule:
  import unittest

import ../../lib/enet/enet

import ../../threads
import ../../entities
import ../../messages
import ../../loop


type
  EnetNetworkSystem* {.inheritable.} = object
    host*: ptr Host
    connectedPeers*: HashSet[ptr Peer]

  EnetClientNetworkSystem* = object of EnetNetworkSystem
    entitiesMap: Table[Entity, Entity]  # table for converting remote Entity to local one

  EnetServerNetworkSystem* = object of EnetNetworkSystem


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

  EntityMessage* = object of NetworkMessage
    ## A message that is related to (or affects) an Entity. This message should not be used directly. Instead, inherit your own message type from this one.
    entity*: Entity

  CreateEntityMessage* = object of EntityMessage
    ## Message that notifies systems about entity creation.
    discard

  DeleteEntityMessage* = object of EntityMessage
    ## Message that notifies systems about entity deletion.
    discard


# there's no sense to pack pointer to Peer, so it will be nil when packed/unpacked
proc pack_type*[ByteStream](stream: ByteStream, self: ptr Peer) =
  stream.pack(nil)

proc unpack_type*[ByteStream](stream: ByteStream, self: var ptr Peer) =
  self = nil
  # self = cast[ptr Peer](alloc(sizeof(Peer)))

register ConnectMessage
register DisconnectMessage
register ConnectionOpenedMessage
register ConnectionClosedMessage

register CreateEntityMessage
register DeleteEntityMessage


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

method netSend*(self: ref EnetNetworkSystem, message: ref Message, peer: ptr Peer = nil,
           channelId: uint8 = 0, reliable: bool = false, immediate: bool = false) {.base.} =
  var
    data: string = message.msgpack()
    packet = enet.packet_create(
      data.cstring,
      data.len.csize_t,  # do not read trailing \0
      if reliable: enet.PACKET_FLAG_RELIABLE else: enet.PACKET_FLAG_UNRELIABLE,
    )

  let sendSign = if reliable: "==>" else: "-->"
  logging.debug &"{sendSign} Sending {message} (packed as \"{data.stringify}\", len={data.len})"

  if peer.isNil:
    self.host.host_broadcast(channelId, packet)

  else:
    if enet.peer_send(peer, channelId, packet) != 0:
      logging.error &"Could not send {packet[]} to {peer[]}"
      return

  if immediate:
    self.host.host_flush()

method init*(self: ref EnetServerNetworkSystem, numConnections: csize_t = 32, numChannels: csize_t = 1, inBandwidth: uint32 = 0, outBandwidth: uint32 = 0, port: Port = Port(11477)) {.base.} =

  if enet.initialize() != 0:
    const err = "An error occurred during initialization"
    logging.fatal(err)
    raise newException(LibraryError, err)

  var address = Address(host: HOST_ANY, port: port.uint16)

  self.host = host_create(address.addr, numConnections, numChannels, inBandwidth, outBandwidth)
  if self.host == nil:
    raise newException(LibraryError, &"An error occured while trying to init host; maybe port {port} is already in use?")

  logging.debug &"{self[].type.name} initialized on port {port}"

method init*(self: ref EnetClientNetworkSystem, numConnections: csize_t = 32, numChannels: csize_t = 1, inBandwidth: uint32 = 0, outBandwidth: uint32 = 0) {.base.} =
  if enet.initialize() != 0:
    const err = "An error occurred during initialization"
    logging.fatal(err)
    raise newException(LibraryError, err)

  self.host = host_create(nil, numConnections, numChannels, inBandwidth, outBandwidth)
  if self.host == nil:
    raise newException(LibraryError, "An error occured while trying to init host")

  logging.debug &"{self[].type.name} initialized"

method connect*(self: ref EnetNetworkSystem, host: string, port: Port, numChannels = 1) {.base.} =
  var address: Address
  discard address_set_host(address.addr, host)
  address.port = port.uint16

  if self.host.host_connect(address.addr, numChannels.csize_t, 0.uint32).isNil:
    raise newException(LibraryError, "Could not establish connection")

  # further connection success / failure is handled by ``handle`` method

method disconnect*(self: ref EnetNetworkSystem, peer: ptr Peer) {.base, gcsafe.} =
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

method disconnect*(self: ref EnetNetworkSystem) {.base.} =
  for peer in self.connectedPeers:
    self.disconnect(peer)

method processLocal*(self: ref EnetNetworkSystem, message: ref Message) {.base.} =
  ## Process message from any local system.
  logging.warn &"No rule for processing local {message}, discarding"

method processLocal*(self: ref EnetNetworkSystem, message: ref NetworkMessage) =
  ## Any NetworkMessage from local system is sent to peer, or broadcasted if peer is nil.
  ## Pay attention that by default messages are sent reliably which adds overhead.
  self.netSend(message, peer=message.peer, reliable=true)

method processRemote*(self: ref EnetNetworkSystem, message: ref NetworkMessage) {.base.} =
  logging.warn &"No rule for processing remote {message}, discarding"

method handle*(self: ref EnetNetworkSystem, event: Event) {.base.} =
  ## Handles Enet events.
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

      if not (message of ref NetworkMessage):
        logging.warn &"Received message which is not NetworkMessage, discarding"
        return

      # include sender info into the message
      ((ref NetworkMessage) message).peer = event.peer

      logging.debug &"<-- Received {message} from peer {event.peer[]}"
      self.processRemote((ref NetworkMessage)message)  # TODO: event.channelID data is missing in message

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

method poll*(self: ref EnetNetworkSystem) {.base.} =
  ## Check for new events and process them
  var event: Event

  while true:  # TODO: maybe add limit to number of processed events
    let status = self.host.host_service(event.addr, 0.uint32)
    if status > 0:
      self.handle(event)
    elif status == 0:
      break
    else:
      logging.error &"Error while polling for new event"

method dispose*(self: ref EnetNetworkSystem) {.base.} =
  ## Destroy current host and deinitialize enet.
  self.disconnect()
  self.host.host_destroy()
  enet.deinitialize()


# ---- handlers ----
## Network system should send outgoing messages as soon as possible. If we store outgoing messages as usual, they will be processed only after all network i/o done (see ``NetworkSystem.update`` method). Thus we will lose exactly one loop cycle before actually sending the message. To avoid this case, we don't store and process any outgoing messages. Instead, we instantly request enet to send them. When ``NetworkSystem`` is updated, it sends all outgoing messages, receives new ones and then processes all stored messages.
##
## Sometimes ``NetworkSystem`` may need to store and process message instead of sending it. For example, ``NetworkSystem`` receives ``SystemReadyMessage`` when all enet internals are initialized. This message should be processed, not sent over the network. To achieve this, we define custom ``store`` method which stores the message (``procCall self.as(ref System).store(message)``).
##
## Security note: all external messages from other peers are discarded by default. This prevents hackers from sending control messages (like ``ConnectMessage``) to remote peers. All network protection should be done inside ``store`` methods, thus ``process`` method receives only trusted messages.


method processLocal*(self: ref EnetClientNetworkSystem, message: ref ConnectMessage) =
  ## When receiving ``ConnectMessage`` from any local system, try to connect to the address specified.
  ##
  ## As a most common case, peer may connect to only one another peer (client connects to only one server). Thus all existing connections will be closed before establishing new one. However, if it's not your case and you want to connect to multiple servers simultaneously, you can dismiss this restriction by overriding this method.

  logging.debug &"Disconnecting"
  self.disconnect()

  logging.debug &"Connecting to '{message.host}:{message.port}'"
  self.connect(message.host, message.port)


method processLocal*(self: ref EnetNetworkSystem, message: ref DisconnectMessage) =
  ## When receiving ``DisconnectMessage`` from any local system, close all connections.
  logging.debug "Disconnecting"
  self.disconnect()


method processLocal*(self: ref EnetClientNetworkSystem, message: ref ConnectionClosedMessage) =
  ## Remove all entity mappings when client disconnects from external peer.
  self.entitiesMap.clear()


method processRemote*(self: ref EnetClientNetworkSystem, message: ref EntityMessage) =
  ## Every entity message requires converting remote Entity to local one. Call this in every method which processes ``EntityMessage`` subtypes.

  # TODO: When client just connected, it may receive entities messages _before_ those entities were actualy created, thus producing this warning. State management system would fix this.
  if not self.entitiesMap.hasKey(message.entity):
    logging.warn &"No local entity found for remote entity {message.entity} in message {message}"
    return

  message.entity = self.entitiesMap[message.entity]


method processRemote*(self: ref EnetClientNetworkSystem, message: ref CreateEntityMessage) =
  ## When client's network system receives this message, it creates an ``Entity`` and updates remote-local entity conversion table.
  assert(not self.entitiesMap.hasKey(message.entity), &"Local entity already exists for this remote entity: {message.entity}")

  let entity = newEntity()
  self.entitiesMap[message.entity] = entity
  logging.debug &"Created new mapping: {message.entity} -> {entity}"

  procCall self.processRemote((ref EntityMessage)message)  # map entity


method processRemote*(self: ref EnetClientNetworkSystem, message: ref DeleteEntityMessage) =
  ## When client's network system receives this message, it removes the entity and updates remote-local entity conversion table.
  assert(self.entitiesMap.hasKey(message.entity), &"No local entity found for this remote entity: {message.entity}")

  let localEntity = self.entitiesMap[message.entity]
  self.entitiesMap.del(message.entity)
  localEntity.delete()
  logging.debug &"Client deleted entity {localEntity}"


method run*(self: ref EnetNetworkSystem) {.base.} =
  loop(frequency=60) do:
    # process (send) local messages
    while true:
      let message = tryRecv()
      if message.isNil:
        break

      self.processLocal(message)

    # retrieve and process remote messages
    self.poll()


when isMainModule:
  type CustomMessage = object of NetworkMessage
    field: int

  register CustomMessage

  method getPeer(self: ref Message): ptr Peer {.base.} = raise newException(ValueError, "Getting Peer of base Message type")
  method getPeer(self: ref CustomMessage): ptr Peer = self.peer

  suite "System tests":
    test "Packing NetworkMessage":
      var message: ref Message

      let peer = cast[ptr Peer](alloc0(sizeof(Peer)))  # some random peer
      message = (ref CustomMessage)(peer: peer)
      assert not message.getPeer.isNil

      let packed = message.msgpack()
      # echo &"Packed NetworkMessage as '{packed.stringify()}'"
      message = packed.msgunpack()
      assert message.getPeer.isNil

    test "Running inside thread":
      spawn("client") do:
        let system = new(EnetClientNetworkSystem)
        system.init()
        system.run()
        system.dispose()

      spawn("server") do:
        let system = new(EnetServerNetworkSystem)
        system.init()
        system.run()
        system.dispose()

      sleep 1000
