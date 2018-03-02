from strutils import format
import macros

# proc join*(iterable: array|tuple|set|seq, delimiter: string): string =  # TODO: make iterable of type "iterable" or something
#   var i = 0
#   let length = iterable.len()
  
#   result = ""
#   for item in iterable:
#     result.add($item)
#     i += 1
#     if i != length:
#       result.add($delimiter)

proc index*[K, V](iterable: array[K, V], value: V): K {.raises: [ValueError].} =  # TODO: make iterable of type "iterable" or something
  for index, item in iterable.pairs():
    if item == value:
      return index

  raise newException(ValueError, "Cannot find value $value".format([
    "value", value,
  ]))

# proc getVersion*(versionFile:string): string {.compileTime.} =
#   staticRead(versionFile)


# proc getAppPath*(): string =
#   result = currentSourcePath()


# TODO: add logger helper - include file name (and possibly line) in log message

template notImplemented*() =
  doAssert(false, "Not implemented")


macro importString*(path, alias: static[string]): untyped =
  result = newNimNode(nnkImportStmt).add(
    newNimNode(nnkInfix).add(
      newIdentNode("as")
    ).add(
      newIdentNode(path)
    ).add(
      newIdentNode(alias)
    )
  )