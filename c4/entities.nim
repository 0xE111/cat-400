## This module contains ECS (Entity-Component-System) implementation.

import tables
export tables
import strformat
import logging

import messages

when isMainModule:
  import unittest
  import threads
  import sequtils


type Entity* = int16  ## Entity is just an int which may have components of any type. Zero entity is reserved as "not initialized"
  # uint doesn't check boundaries

var entities: set[Entity]  # set[int32] won't compile


# ---- Entity ----
proc isInitialized*(self: Entity): bool =
  ## Checks whether entity was initialized using `newEntity()`.
  self != 0

proc newEntity*(): Entity =
  ## Return new Entity or raise error if limit exceeded
  result = low(Entity)
  while result in entities or not result.isInitialized:
    result += 1  # TODO: pretty dumb, use random or `lastUsedID` instead

  entities.incl(result)  # add entity to global entities registry

iterator items*(): Entity =
  for entity in entities:
    yield entity

# ---- Components ----

# Here goes a hacky code.
# Entity may have as much components as desired. For each type (component) there is a separate table ``Table[Entity, <component type>]``. This table is created automatically by compiler using {.global.} pragma.
# However, we want to delete all components when Entity is deleted. Since components tables are created automatically, we don't have a list of tables to delete from. The only way to know which tables require deletion of components is to create a component destructor for that specific table when it is initialised, and add each destructor to a sequence.
# When Entity is deleted, call all destructors from that sequence.
# The idea is quite simple, but ``{.global.}`` variables have a bit complicated behaviour. In order tomake it working we need to make destructors sequence ``{.global.}`` too.

var destructors {.global.}: seq[proc(entity: Entity)] = @[]


proc initComponentTable(T: typedesc): Table[Entity, T] =
  # Creates a components table for specific type, as well as destructor proc for that type
  destructors.add(
    proc(entity: Entity) = entity.del(T)
  )
  initTable[Entity, T]()


proc getComponents*(T: typedesc): var Table[Entity, T] =
  ## Returns a table of components of specific type ``T`` (``Table[Entity, T]``)
  {.gcsafe.}:  # TODO: this is a bullshit
    var table {.global.} = initComponentTable(T)
    return table

proc delete*(entity: Entity) =
  ## Delete the Entity and all its components. Each component will be deleted as well.
  for destructor in destructors:
    destructor(entity)

  if not entity in entities:
    logging.warn &"Trying to delete entity {entity}, but it doesn't exist"
  entities.excl(entity)  # will not alert if entity does not exist

proc flush*() =
  ## Removes all entities
  for entity in entities:
    entity.delete()

# ---- CRUD for components ----
template has*(entity: Entity, T: typedesc): bool =
  ## Checks whether ``entity`` has component of type ``T``
  assert entity.isInitialized, "Entity is not initialized, possibly forgot to call `newEntity()`"

  getComponents(T).hasKey(entity)

template del*(entity: Entity, T: typedesc) =
  ## Deletes component ``T`` from ``entity``, or does nothing if ``entity`` doesn't have such a component
  assert entity.isInitialized, "Entity is not initialized, possibly forgot to call `newEntity()`"

  getComponents(T).del(entity)

template `[]`*(entity: Entity, T: typedesc): var typed =
  ## Returns ``T`` component for ``entity``. Make sure the component exists before retrieving it.
  assert entity.isInitialized, "Entity is not initialized, possibly forgot to call `newEntity()`"

  tables.`[]`(getComponents(T), entity)

template `[]=`*(entity: Entity, T: typedesc, value: T) =
  ## Attaches new component ``T`` to an ``entity``. Previous component (if exists) will be deleted.
  assert entity.isInitialized, "Entity is not initialized, possibly forgot to call `newEntity()`"

  entity.del(T)
  tables.`[]=`(getComponents(T), entity, value)  # N.B. non-ref ``value`` is copied!


when isMainModule:
  type
    PhysicsComponent = object
      value: int

  suite "Entities tests":
    test "Undefined entity":
      expect AssertionError:
        var entity: Entity
        entity[PhysicsComponent] = PhysicsComponent(value: 5)

    test "Basic usage":
      let
        entity1 = newEntity()
        entity2 = newEntity()

      entity1[PhysicsComponent] = PhysicsComponent(value: 3)
      let componentTableAddr1 = getComponents(PhysicsComponent).addr
      entity2[PhysicsComponent] = PhysicsComponent(value: 10)
      let componentTableAddr2 = getComponents(PhysicsComponent).addr

      check:
        entity1[PhysicsComponent].value == 3
        componentTableAddr1 == componentTableAddr2

      entity1.del(PhysicsComponent)
      check:
        not entity1.has(PhysicsComponent)
      entity1.delete()
      check:
        entity1 notin entities

      entity2.del(PhysicsComponent)
      entity2.delete()

    test "Auto-destruction of components":
      let entity = newEntity()

      entity[PhysicsComponent] = PhysicsComponent()
      entity.delete()

      check:
        not entity.has(PhysicsComponent)

    test "Multithreading support":
      discard newEntity()

      spawn("thread1"):
        let entity2 = newEntity()
        entity2[PhysicsComponent] = PhysicsComponent(value: 5)

      spawn("thread2"):
        let entity3 = newEntity()
        entity3[int] = 3

      joinAll()
      check:
        toSeq(items()).len == 3
