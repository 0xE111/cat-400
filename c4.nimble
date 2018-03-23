from strutils import format, split, join
import strformat

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
license = "MIT"

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
