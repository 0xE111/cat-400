import strutils
import distros
import ospaths
import strformat


version = "0.1"
author = "Anonymous"
license = "MIT"

skipDirs = @["build"]

requires "sdl2_nim >= 2.0.8"
when defined(linux):
  requires "x11 >= 1.1"

when defined(nimdistros):
  import distros

  if detectOs(ArchLinux):
    foreignDep "sdl"
    foreignDep "enet"
    foreignDep "ogre"
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
    assetsSrc = thisDir() / "assets"
    assetsDst = buildDir / "assets"

  if not dirExists(assetsSrc):
    echo &"Assets source dir does not exist: {assetsSrc}"
    return

  echo &"Collecting assets into {assetsDst}"
  copyDir(assetsSrc, assetsDst)
