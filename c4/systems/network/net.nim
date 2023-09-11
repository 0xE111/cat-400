import std/tables
import times

import netty

import ../../systems
import ../../entities
import ../../messages
import ../../threads
import ../../logging
import ../../sugar

const
  default_port: uint16 = 8765
  pingInterval: float64 = 2.0

type
  NetworkSystem* = object of System
    reactor: netty.Reactor

  ServerNetworkSystem* = object of NetworkSystem

  ClientNetworkSystem* = object of NetworkSystem
    lastPingAttemptTime: float64 = 0.0
    entitiesMap: Table[Entity, Entity]

  ServerInitMessage* = object of messages.Message
    host*: string = "127.0.0.1"
    port*: uint16 = defaultPort

  ClientInitMessage* = object of messages.Message

  ConnectMessage* = object of messages.Message
    host*: string = "127.0.0.1"
    port*: uint16 = defaultPort

  DisconnectMessage* = object of messages.Message

  NetworkMessage* = object of messages.Message
    connection*: Connection = nil

  HelloMessage* = object of NetworkMessage
  PingMessage* = object of NetworkMessage


proc `$`*(self: Connection): string =
  if self.isNil: "nil" else: $self.id

register ConnectMessage
register DisconnectMessage
register NetworkMessage
register HelloMessage
register PingMessage


method receive*(self: ref NetworkSystem, message: ref NetworkMessage) {.base, gcsafe.} =
  warn "dropping unhandled network message", message

method receive*(self: ref NetworkSystem, message: ref PingMessage) =
  discard

method update*(self: ref NetworkSystem, delta: float) {.gcsafe.} =
  var message: ref messages.Message

  self.reactor.tick()

  for connection in self.reactor.newConnections:
    debug "new connection detected", connection

  for connection in self.reactor.deadConnections:
    debug "connection closed", connection

  for rawMessage in self.reactor.messages:
    try:
      message = rawMessage.data.msgunpack()
    except Exception as exc:
      error "message unpacking failed", rawMessage, exc=exc.msg
      continue

    if not (message of (ref NetworkMessage)):
      warn "discarding message not of NetworkMessage type", message
      continue

    message.as(ref NetworkMessage).connection = rawMessage.conn
    debug "received message", message
    self.receive(message.as(ref NetworkMessage))

method send*(self: ref NetworkSystem, message: ref NetworkMessage) {.base, gcsafe.} =
  debug "sending message", message

  let payload = message.msgpack()
  if message.connection.isNil:
    for connection in self.reactor.connections:
      self.reactor.send(connection, payload)
  else:
    self.reactor.send(message.connection, payload)

method process*(self: ref NetworkSystem, message: ref NetworkMessage) {.gcsafe.} =
  self.send(message)


# -------------------------------- server --------------------------------

method process*(self: ref ServerNetworkSystem, message: ref ServerInitMessage) =
  self.reactor = netty.newReactor(message.host, message.port.int)
  debug "server network initialized", host=message.host, port=message.port


# -------------------------------- client --------------------------------

method update*(self: ref ClientNetworkSystem, dt: float) =
  procCall self.as(ref NetworkSystem).update(dt)

  for connection in self.reactor.connections:
    if epochTime() - max(connection.lastActiveTime, self.lastPingAttemptTime) > pingInterval:
      self.lastPingAttemptTime = epochTime()
      self.send((ref PingMessage)(connection: connection))


method process*(self: ref ClientNetworkSystem, message: ref ClientInitMessage) =
  self.reactor = netty.newReactor()
  debug "client network initialized"

method process*(self: ref ClientNetworkSystem, message: ref ConnectMessage) =
  let connection = self.reactor.connect(message.host, message.port.int)
  info "connection established", host=message.host, port=message.port
  self.send((ref HelloMessage)(connection: connection))

method process*(self: ref ClientNetworkSystem, message: ref DisconnectMessage) =
  if self.reactor.connections.len == 0:
    warn "received disconnect message while not connected"
    return

  for connection in self.reactor.connections:
    self.reactor.disconnect(connection)
  info "disconnected"
