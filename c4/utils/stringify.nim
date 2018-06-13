import typetraits
export typetraits.name


template strMethod*(T: typedesc) =
  method `$`*(self: ref T): string = T.name
