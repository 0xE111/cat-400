from strutils import format

# Package
version = staticRead("c4/version.txt")
author = "c0ntribut0r"
description = "Game framework"
license = "MIT"

# Dirs
skipDirs = @["samples"]

# Dependencies
requires "nim >= 0.17.3"

# Tasks
task tag, "Create a release: add git tag and update version.txt file":
  let
    file = "c4/version.txt"
    currentVersion = staticRead(file)
    newVersion = staticExec("git describe --tags --abbrev=0")
  if newVersion == currentVersion:
    raise newException(ValueError, "Version hasn't changed ($cur)".format(["cur", currentVersion]))

  writeFile(file, newVersion)
  echo("Updated version [$cur] -> [$new]".format([
      "cur", currentVersion,
      "new", newVersion,
  ]))
