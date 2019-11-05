import os

include "c4.nims"

const buildDir = thisDir() / "build"

# Compilter switches
switch("nimcache", buildDir / "nimcache")
switch("out", buildDir / "sandbox")
switch("debugger", "native")