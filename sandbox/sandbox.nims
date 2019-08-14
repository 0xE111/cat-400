import os

include "c4.nims"
include "c4/systems/video/ogre.nims"

const buildDir = thisDir().parentDir.parentDir / "build"

# Compilter switches
switch("nimcache", buildDir / "nimcache")
switch("out", buildDir / "sandbox")
switch("debugger", "native")
