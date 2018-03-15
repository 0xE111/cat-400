import macros
from ospaths import `/`, parentDir
from os import fileExists

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
  projectDir {.strdefine.}: string = nil


template load*(module: static[string]): untyped =
  const customModule = projectDir / module
  when fileExists(customModule & ".nim"):  # try to import custom module from project root
      echo "> Using custom module " & customModule
      importString(customModule)
  else:  # import default implementation
      importString(frameworkDir / module)
