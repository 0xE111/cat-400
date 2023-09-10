import std/tables

import netty

import ../../systems
import ../../entities
import ../../messages
import ../../threads
import ../../logging

const
  default_port: uint16 = 8765

type
  NetworkSystem* = object of System
    reactor: netty.Reactor

  ServerNetworkSystem* = object of NetworkSystem

  ClientNetworkSystem* = object of NetworkSystem
    connection: Connection
    entitiesMap: Table[Entity, Entity]

  ServerInitMessage* = object of messages.Message
    host*: string = "127.0.0.1"
    port*: uint16 = default_port

  ClientInitMessage* = object of messages.Message

  ConnectMessage* = object of messages.Message
    host*: string = "127.0.0.1"
    port*: uint16 = default_port

  DisconnectMessage* = object of messages.Message

  NetworkMessage* = object of messages.Message
    connectionId*: uint32

  ConnectedMessage* = object of NetworkMessage
  DisconnectedMessage* = object of NetworkMessage


method process*(self: ref ServerNetworkSystem, message: ref ServerInitMessage) =
  self.reactor = netty.newReactor(message.host, message.port.int)
  debug "server network initialized", host=message.host, port=message.port

method update*(self: ref ServerNetworkSystem, delta: float) =
  var message: ref messages.Message

  self.reactor.tick()

  for connection in self.reactor.newConnections:
    debug "new connection detected", connection
    (ref ConnectedMessage)(connectionId: connection.id).send(threadID)

  for connection in self.reactor.deadConnections:
    debug "connection closed", connection
    (ref DisconnectedMessage)(connectionId: connection.id).send(threadID)

  for rawMessage in self.reactor.messages:
    try:
      message = rawMessage.data.msgunpack()
      debug "server received message", message
    except Exception as exc:
      error "message unpacking failed", rawMessage, exc=exc.msg
      continue

method update*(self: ref ClientNetworkSystem, delta: float) =
  var message: ref messages.Message

  self.reactor.tick()

  for rawMessage in self.reactor.messages:
    try:
      message = rawMessage.data.msgunpack()
      debug "client received message", message
    except Exception as exc:
      error "message unpacking failed", rawMessage, exc=exc.msg
      continue

method process*(self: ref ClientNetworkSystem, message: ref ClientInitMessage) =
  self.reactor = netty.newReactor()

method process*(self: ref ClientNetworkSystem, message: ref ConnectMessage) =
  self.connection = self.reactor.connect(message.host, message.port.int)
  info "connection established", host=message.host, port=message.port

method process*(self: ref ClientNetworkSystem, message: ref DisconnectMessage) =
  if self.connection == nil:
    warn "received disconnect message while not connected"
    return

  self.reactor.disconnect(self.connection)
  self.connection = nil
  info "disconnected"

method process*(self: ref ClientNetworkSystem, message: ref NetworkMessage) =
  if self.connection == nil:
    warn "received network message while not connected"
    return

  debug "forwarding message to server", message
  self.reactor.send(self.connection, message.msgpack())
  debug "message sent to server", message
