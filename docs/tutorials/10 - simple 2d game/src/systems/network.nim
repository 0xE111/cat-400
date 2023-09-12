import std/tables

import c4/entities
import c4/systems/network/net


type
  ServerNetworkSystem* = object of net.ServerNetworkSystem

  ClientNetworkSystem* = object of net.ClientNetworkSystem
    entitiesMap*: Table[Entity, Entity]  # conversion from server entity to client entity
