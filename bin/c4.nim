## Supplementary tools
import parseopt
import strformat
import os
import osproc
import sequtils
import strutils

import cligen


proc init(preset: string = "base", name: string) =
  var srcDir = execProcess("nimble path c4")
  srcDir.stripLineEnd()

  let
    presetsDir = srcDir / "c4" / "presets"
    presets = toSeq(walkDir(presetsDir, relative=true)).mapIt(it[1])

  if not (preset in presets):
    echo &"Unknown preset \"{preset}\", possible values are: {presets.join(\", \")}"
    return

  let projectDir = $CurDir / name
  createDir(projectDir)

  copyDir(presetsDir / "base", projectDir)
  if preset != "base":
    copyDir(presetsDir / preset, projectDir)

  moveFile(projectDir / "project.nimble", projectDir / &"{name}.nimble")
  moveFile(projectDir / "project.nims", projectDir / &"{name}.nims")
  moveFile(projectDir / "project.nim", projectDir / &"{name}.nim")

  echo &"Initialized \"{preset}\" preset in \"{name}\" directory"
  return


when isMainModule:
  dispatchMulti([init])
