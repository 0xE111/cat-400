from strutils import split

# Constants
const
  versionFile = "version.txt"
  pinnedVersion = staticRead(versionFile)

# Package
version = pinnedVersion.split('-')[0]  # don't include number of updates
author = "c0ntribut0r"
description = "Enet network library wrapper"
license = "MIT"

# Dirs
skipDirs = @["headers"]

# Dependencies
requires "nim >= 0.17.3"
