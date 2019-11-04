## Supplementary tools
import parseopt
import strformat
import os
import osproc
import sequtils
import strutils


proc main() =
  var srcDir = execProcess("nimble path c4")
  srcDir.stripLineEnd()

  let
    params = commandLineParams()
    presetsDir = srcDir / "c4" / "presets"
    presets = toSeq(walkDir(presetsDir, relative=true)).mapIt(it[1])
    help = &"""
      Supplementary tools for the framework. Available commands:

        ○ init [{presets.join("|")}] - initialize new project based on preset
    """

  if params.len == 0:
    echo help
    return

  if params[0] == "init":
    let preset = if params.len == 1: "scratch" else: params[1]
    if not (preset in presets):
      echo &"Unknown preset \"{preset}\", possible values are: {presets.join(\", \")}"
      return

    copyDir(presetsDir / preset, $CurDir)
    echo &"Initialized \"{preset}\" preset"

    return

  else:
    echo &"Unknown command \"{params[0]}\""
    return

  echo help


when isMainModule:
  main()
