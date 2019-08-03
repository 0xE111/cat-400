import strformat
import c4/core/entities

# 
type Health = object
  value: uint8

proc attach(self: var Health) =
  echo "I'm born!"
  self.value = 100

proc detach(self: Health) =
  echo "I'm dead..."

let player = newEntity()
let chest = newEntity()

proc printHealth(self: Entity) =
  if self.has(Health):
    echo &"Entity {self} health: {player[Health].value}"

  else:
    echo &"Entity {self} has no <Health> component!"

player[Health] = Health()
player.printHealth()  # Entity -32768 health: 100
chest.printHealth()  # Entity -32767 has no <Health> component!

proc poison(self: var Health) =
  self.value -= 10

player[Health].poison()
player.printHealth()  # Entity -32768 health: 90

player[Health].value = 100
player.printHealth()

# player[Health] = Health()
# or
# player.del(Health)
# or delete entire entity and all its components
player.delete()
