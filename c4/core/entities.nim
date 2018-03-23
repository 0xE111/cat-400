from tables import Table, newTable


type
  Entity* = int16  # uint doesn't check boundaries

var
  entities: set[Entity] = {}  # set[int32] won't compile


# ---- Entity ----
proc newEntity*(): Entity =
  result = low(Entity)
  while result in entities:
    result += 1  # TODO: pretty dumb

  entities.incl(result)  # add entity to global entities registry

proc delete*(entity: Entity) =
  entities.excl(entity)  # will not alert if entity does not exist
  # TODO: delete all components related to this entity

# ---- Components ----
proc getComponents*(t: typedesc): ref Table[Entity, t] =
  ## Returns components for all entities (Table: key=Entity, value=component)
  var table {.global.} = newTable[Entity, t]()
  return table

# high-level entity wrappers
proc setComponent*(entity: Entity, t: typedesc; value: t) {.inline.} = getComponents(t).add(entity, value)
proc hasComponent*(entity: Entity, t: typedesc): bool {.inline.} = getComponents(t).hasKey(entity)
proc getComponent*(entity: Entity, t: typedesc): var t {.inline.} = getComponents(t)[entity]
proc deleteComponent*(entity: Entity, t: typedesc) {.inline.} = getComponents(t).del(entity)

# short aliases
proc `[]=`* (entity: Entity, t: typedesc; value: t) {.inline.} = entity.setComponent(t, value)
proc `[]`* (entity: Entity, t: typedesc): var t {.inline.} = entity.getComponent(t)
