import strutils
import strformat
import ospaths

# Constants
const
  versionFile = "c4/version.txt"
  pinnedVersion = staticRead(versionFile)

# Helpers
proc getGitVersion*(): string {.compileTime.} =
  staticExec("git describe --tags --long").split('-')[0..^2].join("-")

# Package
version = pinnedVersion.split('-')[0]  # don't include number of updates
author = "c0ntribut0r"
description = "Game framework"
license = staticRead("LICENSE").splitLines()[0]

# Dirs
skipDirs = @["sample"]

# Dependencies
requires "nim >= 0.17.3"
requires "msgpack4nim >= 0.2.1"

# Tasks
task pinVersion, "Update version file":
  const gitVersion = getGitVersion()

  if gitVersion != pinnedVersion:
    writeFile(versionFile, gitVersion)
    discard staticExec("git add " & versionFile)
    discard staticExec("git commit --amend --no-edit")
    echo(&"Updated version {pinnedVersion} -> {gitVersion}")


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
      discard staticExec(&"nim doc2 -o={destFile} {file}")

  for dir in src.listDirs:
    let (head, tail) = dir.splitPath()
    if not tail.startsWith("_") and tail != nimcacheDir():
      dirGenDocs(dir, dst)

task genDocs, "Generate doc files":  
  rmDir "docs"
  dirGenDocs("c4", "docs")
