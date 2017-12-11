from strutils import format, split

# Package
version = staticRead("c4/version.txt").split('-')[0]
author = "c0ntribut0r"
description = "Game framework"
license = "MIT"

# Dirs
skipDirs = @["samples"]

# Dependencies
requires "nim >= 0.17.3"

# Tasks
task pinVersion, "Update version.txt file":
  const
    file = "c4/version.txt"
    currentVersion = staticRead(file)
    newVersion = staticExec("git describe --tags")  # honestly this is a previous version
    
  if newVersion == currentVersion:
    raise newException(ValueError, "Version hasn't changed ($cur)".format(["cur", currentVersion]))

  writeFile(file, newVersion)
  echo("Updated version [$cur] -> [$new]".format([
      "cur", currentVersion,
      "new", newVersion,
  ]))
