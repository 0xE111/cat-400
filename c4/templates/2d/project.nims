import os

include "c4/lib/ogre/ogre.nims"
include "c4/lib/ogre/ogre_sdl.nims"

const buildDir = thisDir() / "build"

switch("threads", "on")
switch("multimethods", "on")
switch("nimcache", buildDir / "nimcache")
switch("out", buildDir / projectName())
