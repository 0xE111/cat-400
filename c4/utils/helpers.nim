from strutils import format


proc index*[K, V](iterable: array[K, V], value: V): K {.raises: [ValueError].} =  # TODO: make iterable of type "iterable" or something
  for index, item in iterable.pairs():
    if item == value:
      return index

  raise newException(ValueError, "Cannot find value $value".format([
    "value", value,
  ]))


# TODO: add logger helper - include file name (and possibly line) in log message

template notImplemented*() =
  doAssert(false, "Not implemented")
