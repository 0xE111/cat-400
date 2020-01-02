Entity-component system
-----------------------

> WARNING: This tutorial is currently outdated.

> Attention! Before reading this tutorial, it's highly recommended to read [the "Component" chapter](https://gameprogrammingpatterns.com/component.html) of Bob Nystrom's awesome "Game Programming Patterns" book.

ECS is one of core parts of `C4`. It allows you to have entities and attach both predefined and custom components (objects) to it.

Entity
------

``Entity`` represents some game entity / object. It may be a tree, or wind, or player - whatever you want to.

Under the hood each entity is nothing but a number, which you may treat as entity ID. In `C4` it's just ``int16``, thus you may have up to ``65 536`` different entities with IDs from ``-32 768`` to ``32 767``. ``int16`` type was chosen because:
* signed ints are checked for boundary errors, so if you try to create entity with ID ``32 767``, it won't be treated as ``-32 768`` - and you'll get an exception;
* 16 bits is maximum for ``set`` type for effectiveness reasons.

Creating new entity
-------------------

To create new entity, call ``newEntity()``. Entity ID will be the smallest unused ID - if IDs are ``[-32 768, -32 767, (missing), -32 765]``, new Entity's ID will be ``-32 766``. If Entity limit is reached, an overflow exception will be thrown.

```nim
# /tmp/test.nim
import c4/entities

let player = newEntity()
echo "Player ID = " & $player  # -32768
while true:
  echo $newEntity()
```

```sh
> nim c -r /tmp/test.nim
Player ID = -32768
...
32764
32765
32766
32767
/tmp/test.nim(4)         test
/home/user/workspace/c4/cat-400/c4/core/entities.nim(31) newEntity
/usr/lib/nim/system/fatal.nim(39) sysFatal
Error: unhandled exception: over- or underflow [OverflowError]
```

Components
----------

Components is some value or instance that you can attach to / retrieve from `Entity`. For example, our `player` entity may have `Health` and `Inventory` components, and we may also add a `chest` entity with only `Inventory` components (chests don't need health component, unless you wanna make chests breakable in your game).

Here are the rules for components:
* Each entity may have as many types of components as you wish. For example, `player` may have `Health`, `Inventory`, `Spells`, `Diseases`, `Sprite`, `Sound`, `Animation`, `WalkState` and more,  depending on your needs.
* Each entity may have only one component of specific class (type). `player` can have no `Health` component, can have one `Health` component, but never two or more;
* Each component should have `attach()` and `dispose()` procs defined - more on it later.

Now we gonna create `Health` component for our game:

```nim
# main.nim
import strformat
import c4/entities

type Health = object
  value: uint8
```

It's recommended to define components as objects. Here health is just `uint8`, but when you game grows you'll definitely need to add something to your `Health` component, and it would be easier to do so if `Health`is already an object.

On the other hand, nothing restricts you from defining `Health` as `ref object`, which may be handy if you want to inherit `Health` and redefine some of its methods.

> Implementation details: for each component type a separate ``Table[Entity, <component type>]`` is created.

Each component should define `attach()` and `detach()` procs:
* `attach()` is called automatically when component is attached to any entity - you may use it to init values of object;
* `detach()` is called automatically when component is detached from any entity, which happens when component is deleted, replaced by other component instance, or when entire entity is deleted - use it to free resources which are held by this component (i.e. "dispose" a component).

```nim
proc attach(self: var Health) =
  echo "I'm born!"
  # let's set default value here
  self.value = 100

proc detach(self: Health) =
  # here we could free exernal resources, for example file handlers
  echo "I'm dead..."
```

Playing with entities
---------------------

Now it's time to create a player. Since `Entity` is just int and usually should not be changed, it's a good practice to use `let` to show and force unmutability.

```nim
let player = newEntity()
let chest = newEntity()
```

To check whether some entity has a specific component, use `has(entity, <component type>)` template:

```nim
proc printHealth(self: Entity) =
  if self.has(Health):
    echo &"Entity {self} health: {self[Health].value}"

  else:
    echo &"Entity {self} has no <Health> component!"
```

To attach new component to entity, use `[]=` template:

```nim
player[Health] = Health()
player.printHealth()  # Entity -32768 health: 100
chest.printHealth()  # Entity -32767 has no <Health> component!
```

Define a proc on `Health` component and use it:

```nim
proc poison(self: var Health) =
  self.value -= 10

player[Health].poison()
player.printHealth()  # Entity -32768 health: 90
```

Or access component attribute directly (note that it works because `Health` is defined in the same module; if it wasn't you'd have to use `*` symbol in attribute definition, i.e. `value*: uint16`):
```nim
player[Health].value = 100
player.printHealth()  # Entity -32768 health: 100
```

To delete a component, use `del(entity, <component type>)` template, or replace it with other component, or delete the entity completely - all these cases will call `detach()`:

```nim
# player[Health] = Health()
# or
# player.del(Health)
# or
player.delete()  # I'm dead...
```

Note that calling `entity.delete()` will `detach()` and remove all its components!
