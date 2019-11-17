import os

include "c4/lib/ogre/ogre.nims"
include "c4/lib/ogre/ogre_sdl.nims"

const buildDir = thisDir() / "build"

# Compilter switches
switch("nimcache", buildDir / "nimcache")
switch("out", buildDir / projectName())
switch("debugger", "native")