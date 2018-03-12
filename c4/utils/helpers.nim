from strutils import format
import macros
from ospaths import `/`, parentDir
from os import fileExists


proc index*[K, V](iterable: array[K, V], value: V): K {.raises: [ValueError].} =  # TODO: make iterable of type "iterable" or something
  for index, item in iterable.pairs():
    if item == value:
      return index

  raise newException(ValueError, "Cannot find value $value".format([
    "value", value,
  ]))


# proc getAppPath*(): string =
#   result = currentSourcePath()


# TODO: add logger helper - include file name (and possibly line) in log message

template notImplemented*() =
  doAssert(false, "Not implemented")


# ---- imports ----
macro importString*(module, alias: static[string]): untyped =
  result = newNimNode(nnkImportStmt).add(
    newNimNode(nnkInfix).add(newIdentNode("as")).add(newIdentNode(module)).add(newIdentNode(alias))
  )

macro importString*(module: static[string]): untyped =
  result = newNimNode(nnkImportStmt).add(
    newIdentNode(module)
  )

const
  frameworkDir = currentSourcePath().parentDir().parentDir()
  projectDir {.strdefine.}: string = nil

template importOrFallback*(module: static[string]): untyped =
  const customModule = projectDir / module
  when fileExists(customModule & ".nim"):  # try to import custom module from project root
    echo "Hint: Using custom module " & customModule
    importString(customModule)
  else:  # import default implementation
    importString(frameworkDir / module)
