from strutils import split
import distros


# Constants
const
  versionFile = "c4/version.txt"
  pinnedVersion = staticRead(versionFile)


# Package
version = pinnedVersion.split('-')[0]  # don't include number of updates
author = "c0ntribut0r"
description = "c4 sample"
license = "MIT"


# Dependencies
requires "nim >= 0.17.3"
requires "c4 >= " & version

if detectOs(Linux):
  foreignDep "sdl"
  foreignDep "enet"
  