import macros
import ospaths
import os
import strutils

# # Unused
# macro importString*(module, alias: static[string]): untyped =
#     result = newNimNode(nnkImportStmt).add(
#       newNimNode(nnkInfix).add(newIdentNode("as")).add(newIdentNode(module)).add(newIdentNode(alias))
#     )
  
macro importString*(module: static[string]): untyped =
  result = newNimNode(nnkImportStmt).add(
      newIdentNode(module)
  )


const
  frameworkDir = currentSourcePath.parentDir.parentDir
  projectDir {.strdefine.}: string = ""


template load*(module: static[string]): untyped =
  const customModule = projectDir / module
  when fileExists(customModule & ".nim"):  # try to import custom module from project root
      echo "> Using custom module " & customModule
      importString(customModule)
  else:  # import default implementation
      importString(frameworkDir / module)


macro importDir*(dir: static[string]): untyped =
  ## Imports all *.nim files from specific dir
  result = newNimNode(nnkStmtList)
  for kind, name in walkDir(dir, relative=true):
    if kind == pcFile and name.endsWith(".nim"):
      result.add(newNimNode(nnkImportStmt).add(newIdentNode(dir / name[0..^(".nim".len + 1)])))
