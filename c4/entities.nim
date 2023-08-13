## This module contains ECS (Entity-Component-System) implementation.

import tables
export tables

import ./logging


# uint doesn't check boundaries, thus int; set[int32] won't compile, thus int16
type Entity* = int16  ## Entity is just an int which may have components of any type. Zero entity is reserved as "not initialized". Please be careful with threading: all threads share the same entities registry, so if you create an entity in one thread, it will be visible in another thread. However, components aren't shared between threads, so you can't create a component in one thread and access it in another thread (which is not recommended anyway).


var entities: set[Entity]

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

iterator iterEntities*(): Entity =
  for entity in entities:
    yield entity

proc getNumEntities*(): int =
  entities.len

# ---- Components ----

# Here goes a hacky code.
# Entity may have as much components as desired. For each type (component) there is a separate table ``Table[Entity, <component type>]``. This table is created automatically by compiler using {.global.} pragma.
# However, we want to delete all components when Entity is deleted. Since components tables are created automatically, we don't have a list of tables to delete from. The only way to know which tables require deletion of components is to create a component destructor for that specific table when it is initialised, and add each destructor to a sequence.
# When Entity is deleted, call all destructors from that sequence.
# The idea is quite simple, but ``{.global.}`` variables have a bit complicated behaviour. In order to make it working we need to make destructors sequence ``{.global.}`` too.

var seenTables {.threadvar.}: seq[pointer]
var destructors {.threadvar.}: seq[proc(entity: Entity)]

proc getComponents*(T: typedesc): var Table[Entity, T] =
  ## Returns a table of components of specific type ``T`` (``Table[Entity, T]``)
  var table {.global, threadvar.}: Table[Entity, T]  # https://github.com/nim-lang/Nim/issues/17552
  # That's what all nim is about: there is some feature like {.global.} which is documented
  # and should work, but after some version update you find out it doesn't; after some googling
  # you find some post on nim forum which says that this feature works but only for primitive types,
  # and for complex types it works ONLY if you split declaration and initialization. Previously
  # you had some additional logic executed only once during initialization, but now you can't do
  # it. You start googling how to create your subtype with custom initialization and guess what?
  # You cannot! Cause in nim there are no "constructors", everyone can initialize whatever he wants
  # in whatever way he wants. So you end up having a global variable of "seen", or "initialized" tables,
  # so that when you get a new one, you execute that "only once" logic. And you pray, you pray that
  # it will work at least a year until Araq decides to change something again, I dunno, implement
  # an 11th garbage collecting algo or some another cool feature like
  # "proc ~(*)@$@ from nullptr by nilvar as ptrref {.fuckoff:[@wat].}". I just wanna write code
  # and be sure that the code does what the documentation says! But that bug is 2yo now.
  let tableAddr = addr(table)
  if tableAddr notin seenTables:
    seenTables.add(tableAddr)
    destructors.add(
      proc(entity: Entity) = entity.del(T)
    )
  return table

proc delete*(entity: Entity) =
  ## Delete the Entity and all its components. Each component will be deleted as well.
  for destructor in destructors:
    destructor(entity)

  if entity notin entities:
    warn "deleting non-existent entity", entity
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
  import unittest
  import c4/threads

  type
    PhysicsComponent = object
      value: int

  suite "Entities tests":
    test "Undefined entity":
      expect AssertionDefect:
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

      spawnThread ThreadID(1):
        let entity2 = newEntity()
        entity2[PhysicsComponent] = PhysicsComponent(value: 5)
        check:
          getNumEntities() == 2

      joinActiveThreads()

      spawnThread ThreadID(2):
        let entity3 = newEntity()
        entity3[int] = 3
        let entity4 = newEntity()
        entity4[string] = "name"
        check:
          getNumEntities() == 4

      joinActiveThreads()
      check:
        getNumEntities() == 4
