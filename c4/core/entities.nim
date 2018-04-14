## This module defines Entity - a base unit for representing a game object.

from tables import Table, newTable, hasKey, del, `[]`, `[]=`, add


type
  Entity* = int16  # uint doesn't check boundaries
  ## Entity is just an int which may have components of any type.

var
  entities: set[Entity] = {}  # set[int32] won't compile


# ---- Entity ----
proc newEntity*(): Entity =
  ## Return new Entity or raises error if limit exceeded
  result = low(Entity)
  while result in entities:
    result += 1  # TODO: pretty dumb

  entities.incl(result)  # add entity to global entities registry

proc delete*(entity: Entity) =
  ## Delete the Entity
  entities.excl(entity)  # will not alert if entity does not exist
  # TODO: delete all components related to this entity

# ---- Components ----
proc getComponents*(t: typedesc): ref Table[Entity, t] =
  ## Returns a table of components for all entities (`Table[Entity, t]`)
  var table {.global.} = newTable[Entity, t]()
  return table

template has*(entity: Entity, t: typedesc): bool = getComponents(t).hasKey(entity)
template del*(entity: Entity, t: typedesc) = getComponents(t).del(entity)
template `[]`*(entity: Entity, t: typedesc): var typed = getComponents(t)[entity]
template `[]=`*(entity: Entity, t: typedesc, value: t) = getComponents(t)[entity] = value
