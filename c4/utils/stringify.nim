import typetraits
import strformat

export typetraits.name


template strMethod*(T: typedesc) =
  ## Defines ``$`` method for selected type ``T``. Output contains type name and all fields' values.
  method `$`*(self: ref T): string = T.name & " " & $self[]
