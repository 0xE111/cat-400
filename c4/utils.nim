from strutils import format


proc join*(iterable: array|tuple|set, delimiter: string): string =  # TODO: make iterable of type "iterable" or something
  var
    i = 0
  let length = iterable.len()
  
  result = ""
  for item in iterable:
    result.add($item)
    i += 1
    if i != length:
      result.add($delimiter)

proc index*[K, V](iterable: array[K, V], value: V): K {.raises: [ValueError].} =  # TODO: make iterable of type "iterable" or something
  for index, item in iterable.pairs():
    if item == value:
      return index

  raise newException(ValueError, "Cannot find value $value".format([
    "value", value,
  ]))
