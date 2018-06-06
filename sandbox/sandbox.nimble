from strutils import split
import distros
import ospaths


# Constants
const
  versionFile = "c4/version.txt"
  pinnedVersion = staticRead(versionFile)
  buildDir = thisDir().parentDir.parentDir / "build"

# Package
version = pinnedVersion.split('-')[0]  # don't include number of updates
author = "c0ntribut0r"
description = "c4 sample"
license = "MIT"


# Dependencies
requires "nim >= 0.18.1"
requires "c4 >= " & version

if detectOs(Linux):
  foreignDep "sdl"
  foreignDep "enet"
  foreignDep "horde3d"
  foreignDep "ode"

proc copyDir(src, dst: string) =
  mkDir(dst)

  for file in src.listFiles:
    echo dst / file.extractFilename
    file.cpFile(dst / file.extractFilename)
  
  for dir in src.listDirs:
    dir.copyDir(dst / dir.splitPath[1])


task collectAssets, "Put all assets into build folder":
  let
    assetsSrc = "assets"
    assetsDst = buildDir / "assets"
  
  if dirExists(assetsSrc):
    echo "Collecting assets into " & assetsDst
    copyDir(assetsSrc, assetsDst)
