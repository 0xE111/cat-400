## This module defines Entity - a base unit for representing a game object.

from tables import Table, newTable, hasKey, del, `[]`, `[]=`


type
  Entity* = int16  # uint doesn't check boundaries

var
  entities: set[Entity] = {}  # set[int32] won't compile


# ---- Entity ----
proc newEntity*(): Entity =
  ## Returns new Entity or raises error if limit exceeded.
  result = low(Entity)
  while result in entities:
    result += 1  # TODO: pretty dumb

  entities.incl(result)  # add entity to global entities registry

proc delete*(entity: Entity) =
  ## Deletes the Entity
  entities.excl(entity)  # will not alert if entity does not exist
  # TODO: delete all components related to this entity

# ---- Components ----
proc getComponents*(t: typedesc): ref Table[Entity, t] =
  ## Returns a table of components for all entities (`Table[Entity, t]`)
  var table {.global.} = newTable[Entity, t]()
  return table

# high-level entity wrappers
# proc setComponent*(entity: Entity, t: typedesc; value: t) {.inline.} = getComponents(t).add(entity, value)
# proc hasComponent*(entity: Entity, t: typedesc): bool {.inline.} = getComponents(t).hasKey(entity)
# # proc getComponent*(entity: Entity, t: typedesc): t = getComponents(t)[entity]  # <-- does not work
# # TODO: https://forum.nim-lang.org/t/3697
# template getComponent*(entity: Entity, t: typedesc): var typed = getComponents(t)[entity]
# proc deleteComponent*(entity: Entity, t: typedesc) {.inline.} = getComponents(t).del(entity)

# ---- aliases ----
# proc has*(entity: Entity, t: typedesc): bool {.inline.} = entity.hasComponent(t)  ## Alias for `hasComponent`
# # proc `[]`*(entity: Entity, t: typedesc): t {.inline.} = entity.getComponent(t)  ## Alias for `getComponent`
# proc `[]=`*(entity: Entity, t: typedesc, value: t) {.inline.} = entity.setComponent(t, value)  ## Alias for `setComponent`

template has*(entity: Entity, t: typedesc): bool = getComponents(t).hasKey(entity)
template del*(entity: Entity, t: typedesc) = getComponents(t).del(entity)
template `[]`*(entity: Entity, t: typedesc): var typed = getComponents(t)[entity]
template `[]=`*(entity: Entity, t: typedesc, value: t) = getComponents(t)[entity] = value
