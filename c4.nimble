import strutils
import strformat
import os

# Package info
version = "0.2.0"
author = "c0ntribut0r"
description = "Game framework"
license = "MPL-2.0"

# srcDir = "c4"
bin = @["bin/c4"]
installDirs = @["c4"]
installExt = @["nim", "nims", "nimble", "txt"]
# skipDirs = @["docs", "sandbox"]

# Dependencies
requires "nim >= 0.20"
requires "msgpack4nim >= 0.2.7"
requires "cligen >= 0.9.41"
requires "fsm >= 0.1.0"
requires "sdl2_nim >= 2.0.9.2"
when defined(linux):
  requires "x11 >= 1.1"


proc dirGenDocs(src, dst: string) =
  mkDir dst

  for file in src.listFiles:
    let (dir, name, ext) = file.splitFile()

    if ext == ".nim" and not name.startsWith("_"):
      echo &"Processing {file}"
      let
        destDir = dst / dir.tailDir
        destFile = destDir / name.addFileExt("html")

      mkDir destDir
      discard staticExec(&"nim doc0 -o={destFile} {file}")

  for dir in src.listDirs:
    let (head, tail) = dir.splitPath()
    if not tail.startsWith("_") and tail != nimcacheDir():
      dirGenDocs(dir, dst)

task genDocs, "Generate doc files":
  const docsDir = "docs" / "ref"
  docsDir.rmDir()
  dirGenDocs("c4", docsDir)
  echo &"Generated documetation at {docsDir}"
