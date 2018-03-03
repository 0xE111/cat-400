from strutils import format, split, join

# Constants
const
  versionFiles = @[
    "c4/version.txt",
    "c4/wrappers/nimenet/version.txt",
  ]
  pinnedVersion = staticRead(versionFiles[0])

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
    for versionFile in versionFiles:
      writeFile(versionFile, gitVersion)
      discard staticExec("git add " & versionFile)

    discard staticExec("git commit --amend --no-edit")
 
    echo("Updated version [$cur] -> [$new]".format([
      "cur", $pinnedVersion,
      "new", $gitVersion,
    ]))
