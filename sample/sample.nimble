from strutils import format, split, join


# Constants
const
  versionFiles = @[
    "c4/version.txt",
    "c4/wrappers/enet/version.txt",
    "c4/wrappers/horde3d/version.txt",
  ]
  pinnedVersion = staticRead(versionFiles[0])

# Helpers
proc getGitVersion*(): string {.compileTime.} =
  staticExec("git describe --tags --long").split('-')[0..^2].join("-")

# Package
version = staticRead("../c4/version.txt").split('-')[0]  # don't include number of updates
author = "c0ntribut0r"
description = "c4 sample"
license = "MIT"


# Dependencies
requires "nim >= 0.17.3"
requires "c4"
