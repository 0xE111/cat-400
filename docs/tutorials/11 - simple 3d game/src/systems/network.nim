import std/tables

import c4/entities
import c4/systems/network/net
import c4/threads

import ../threads
import ../messages


type
  ServerNetworkSystem* = object of net.ServerNetworkSystem

  ClientNetworkSystem* = object of net.ClientNetworkSystem
    entitiesMap*: Table[Entity, Entity]  # conversion from server entity to client entity
