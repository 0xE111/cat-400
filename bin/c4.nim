## Supplementary tools
import strformat
import os
import osproc
import sequtils
import strutils

import cligen


proc init(`template`: string = "base", name: string) =
  var srcDir = execProcess("nimble path c4")
  srcDir.stripLineEnd()

  let
    templatesDir = srcDir / "c4" / "templates"
    templates = toSeq(walkDir(templatesDir, relative=true)).mapIt(it[1])

  if not (`template` in templates):
    echo &"Unknown template \"{`template`}\", possible values are: {templates.join(\", \")}"
    return

  let projectDir = $CurDir / name
  createDir(projectDir)

  copyDir(templatesDir / `template`, projectDir)

  moveFile(projectDir / "project.nimble", projectDir / &"{name}.nimble")
  moveFile(projectDir / "project.nims", projectDir / &"{name}.nims")
  moveFile(projectDir / "project.nim", projectDir / &"{name}.nim")

  echo &"Initialized \"{`template`}\" template in \"{name}\" directory"
  return


when isMainModule:
  dispatchMulti([init])
