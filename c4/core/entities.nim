## This module contains ECS (Entity-Component-System) implementation.
## It has no dependencies with other modules, so you may use it separately in other projects.
##
## Before moving further, please read this excellent article by Robert Nystrom: http://gameprogrammingpatterns.com/component.html
##
## Now that you're familiar with basic concepts, let's see how to work with this particular implementation.
##
## Entity
## ======
##
## ``Entity`` represents some game entity / object. It may be a tree, or wind, or player - whatever you want to.
##
## Under the hood each entity is nothing but a number, which you may treat as entity ID. Here it's just ``int16``, thus you may have up to ``65 536`` different entities with IDs from ``-32 768`` to ``32 767``. ``int16`` type was chosen because:
## * signed ints are checked for boundary errors, so if you try to create entity with ID ``32 767``, it won't be treated as ``-32 768`` - and you'll get an exception;
## * 16 bits is maximum for ``set`` type for effectiveness reasons.
##
## ::
##
##    type Entity* = int16
##
## Entity creation
## ---------------
##
## ``newEntity()`` returns new Entity. Entity ID will be the smallest unused ID - if IDs are ``[-32 768, -32 767, -32 765]``, new Entity's ID will be ``-32 766``. If Entity limit is reached, an exception will be thrown.
##

import tables
import strformat
import logging

import messages
import unittest


type
  Entity* = int16  ## Entity is just an int which may have components of any type.
  # uint doesn't check boundaries

  Component* = concept component
    ## Component is something which has ``init()`` and ``dispose()`` procs.
    ## When component is attached to an Entity (``entity[Component] = component``), it is initialized - ``init()`` is called automatically. When component is detached from entity (deleted ``entity.del(Component)`` or replaced with other component ``entity[Component] = newComponent``), it is disposed - ``dispose()`` is called automatically.
    component.init()
    component.dispose()


var
  entities: set[Entity] = {}  # set[int32] won't compile


# ---- Entity ----
proc newEntity*(): Entity =
  ## Return new Entity or raise error if limit exceeded
  result = low(Entity)
  while result in entities:
    result += 1  # TODO: pretty dumb

  entities.incl(result)  # add entity to global entities registry

# ---- Components ----

# Here goes a hacky code.
# Entity may have as much components as desired. For each type (component) there is a separate table ``Table[Entity, <component type]``. This table is created automatically by compiler using {.global.} pragma.
# However, we want to delete all components when Entity is deleted. Since components tables are created automatically, we don't have a list of tables to delete from. The only way to know which tables require deletion of components is to create a component destructor for that specific table when it is initialised, and add each destructor to a sequence.
# When Entity is deleted, call all destructors from that sequence.
# The idea is quite simple, but ``{.global.}`` variables have a bit complicated behaviour. In order tomake it working we need to make destructors sequence ``{.global.}`` too.

type ComponentDestructor = proc(entity: Entity) {.nimcall.}

proc getComponentDestructors(): var seq[ComponentDestructor] =
  # Returns a sequence of destructors, one for each component
  var destructors {.global.}: seq[ComponentDestructor] = @[]
  return destructors

proc getComponents*(T: typedesc): ref Table[Entity, T]

# proc deleteComponent[t: typedesc](entity: Entity) {.nimcall.} =
#   let component = getComponents(t)[entity]
#   getComponents(t).del(entity)

proc newTableAndDestructor(T: typedesc): ref Table[Entity, T] =
  # Creates a components table for specific type, as well as destructor proc for that type
  result = newTable[Entity, T]()
  getComponentDestructors().add(
    proc(entity: Entity) = entity.del(T)
  )

proc getComponents*(T: typedesc): ref Table[Entity, T] =
  ## Returns a table of components of specific type ``T`` (``Table[Entity, T]``)
  var table {.global.} = newTableAndDestructor(T)
  return table

  # var table {.global.}: TableRef[Entity, t]
  # if table.isNil:
  #   table = newTable[Entity, t]()
  #   if destructors.isNil:  # this line may be called even earlier than `var` declarations of this file
  #     destructors = @[]  # thus we need to init whatever we need
  #   destructors.add(proc(entity: Entity) {.closure.} = echo "Destroyed " & $t & " for entity " & $entity)
  #   # destructors.add(proc(entity: Entity) {.closure.} = discard getComponents(t); echo "OK")
  #   echo "Table just initialized for type " & $t
  # return table

proc delete*(entity: Entity) =
  ## Delete the Entity and all its components. Each component will be deleted as well.
  for destructor in getComponentDestructors():
    destructor(entity)

  if not entity in entities:
    logging.warn &"Trying to delete entity {entity}, but it doesn't exist"
  entities.excl(entity)  # will not alert if entity does not exist

proc flush*() =
  ## Removes all entities
  for entity in entities:
    entity.delete()


# ---- CRUD for components ----
template has*(entity: Entity, T: typedesc[Component]): bool =
  ## Checks whether ``entity`` has component of type ``T``
  getComponents(T).hasKey(entity)

template del*(entity: Entity, T: typedesc[Component]) =
  ## Deletes component ``T`` from ``entity``, or does nothing if ``entity`` doesn't have such a component
  var components = getComponents(T)
  if components.hasKey(entity):
    components[entity].dispose()
    components.del(entity)

template `[]`*(entity: Entity, T: typedesc[Component]): var typed =
  ## Returns ``T`` component for ``entity``. Make sure the component exists before retrieving it.
  getComponents(T)[entity]

template `[]=`*(entity: Entity, T: typedesc[Component], value: T) =
  ## Attaches new component ``T`` to an ``entity``. Previous component (if exists) will be deleted.
  entity.del(T)
  getComponents(T)[entity] = value  # N.B. non-ref ``value`` is copied!
  getComponents(T)[entity].init()


# ---- messages ----
type
  EntityMessage* = object of Message
    ## A message that is related to (or affects) an Entity. This message should not be used directly. Instead, inherit your own message type from this one.
    entity*: Entity

  CreateEntityMessage* = object of EntityMessage
    ## Message that notifies systems about entity creation.
    discard

  DeleteEntityMessage* = object of EntityMessage
    ## Message that notifies systems about entity deletion.
    discard

messages.register(CreateEntityMessage)
messages.register(DeleteEntityMessage)

method isReliable*(self: ref CreateEntityMessage): bool {.inline.} =
  ## This message type is always sent reliably.
  true

method isReliable*(self: ref DeleteEntityMessage): bool {.inline.} =
  ## This message type is always sent reliably.
  true


when isMainModule:
  type
    TestComponent = object
      value: int

  proc init(self: var TestComponent) =
    self.value = 42

  proc dispose(self: TestComponent) =
    discard

  suite "Entities tests":
    test "Auto-initialization of components":
      var
        entity = newEntity()
        component = TestComponent(value: 0)

      entity[TestComponent] = component

      check:
        entity[TestComponent].value == 42

    test "Auto-destruction of components":
      var
        entity = newEntity()
        component = TestComponent()

      entity[TestComponent] = component
      entity.delete()

      check:
        not entity.has(TestComponent)
