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
import typetraits
import logging

import messages
import unittest


type
  Entity* = int16  ## Entity is just an int which may have components of any type.
  # uint doesn't check boundaries


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

proc getComponents*(t: typedesc): ref Table[Entity, t]

# proc deleteComponent[t: typedesc](entity: Entity) {.nimcall.} =
#   let component = getComponents(t)[entity]
#   getComponents(t).del(entity)

proc newTableAndDestructor(t: typedesc): ref Table[Entity, t] =
  # Creates a components table for specific type, as well as destructor proc for that type
  result = newTable[Entity, t]()
  getComponentDestructors().add(
    proc(entity: Entity) = 
      let components = getComponents(t)
      if components.hasKey(entity):
        var component = components[entity]
        
        # component.`=destroy`()
        # components[entity][].`=destroy`()
        components.del(entity)
  )
  

proc getComponents*(t: typedesc): ref Table[Entity, t] =
  ## Returns a table of components of specific type ``t`` (``Table[Entity, t]``)
  var table {.global.} = newTableAndDestructor(t)
  return table

  # var table {.global.}: TableRef[Entity, t] 
  # if table.isNil:
  #   table = newTable[Entity, t]()
  #   if destructors.isNil:  # this line may be called even earlier than `var` declarations of this file
  #     destructors = @[]  # thus we need to init whatever we need
  #   destructors.add(proc(entity: Entity) {.closure.} = echo "Destroyed " & t.name & " for entity " & $entity)
  #   # destructors.add(proc(entity: Entity) {.closure.} = discard getComponents(t); echo "OK")
  #   echo "Table just initialized for type " & $t.name
  # return table

proc delete*(entity: Entity) =
  ## Delete the Entity and all its components
  for destructor in getComponentDestructors():
    destructor(entity)

  if not entity in entities:
    logging.warn &"Trying to delete entity {entity}, but it doesn't exist"
  entities.excl(entity)  # will not alert if entity does not exist

proc flush*() =
  ## Removes all entities
  for entity in entities:
    entity.delete()


template has*(entity: Entity, t: typedesc): bool = getComponents(t).hasKey(entity)
template del*(entity: Entity, t: typedesc) = getComponents(t).del(entity)
template `[]`*(entity: Entity, t: typedesc): var typed = getComponents(t)[entity]
template `[]=`*(entity: Entity, t: typedesc, value: t) = getComponents(t)[entity] = value


# ---- messages ----
type
  EntityMessage* = object of Message
    ## A message that is related to (or affects) an Entity. This message should not be used directly. Instead, inherit your own message type from this one.
    entity*: Entity

  CreateEntityMessage* = object of EntityMessage  ## \
    ## Message that notifies systems about entity creation.
  DeleteEntityMessage* = object of EntityMessage  ## \
    ## Message that notifies systems about entity deletion.

messages.register(CreateEntityMessage)
messages.register(DeleteEntityMessage)


when isMainModule:
  suite "Entities tests":
    test "Check auto-destruction of components":
      var
        ent1 = newEntity()
        ent2 = newEntity()
      
      ent1[int] = 1
      ent1[string] = "Entity 1"
      
      ent2[int] = 2
      
      ent1.delete()
      ent2.delete()
      
      const failMsg = "Component destructors don't work!"
      assert(not ent1.has(string), failMsg)
      assert(not ent2.has(int), failMsg)
