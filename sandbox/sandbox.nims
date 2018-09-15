import ospaths


const buildDir = thisDir().parentDir.parentDir / "build"

# Compilter switches
switch("nimcache", buildDir / "nimcache")
switch("out", buildDir / "sandbox")
switch("debugger", "native")
