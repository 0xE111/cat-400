import ospaths


const buildDir = thisDir().parentDir.parentDir / "build"

# Compilter switches
switch("nimcache", buildDir / "nimcache")
switch("out", buildDir / "sandbox")
switch("debugger", "native")

when defined(windows):
  switch("d", "SDL_VIDEO_DRIVER_WINDOWS")

elif defined(linux):
  switch("d", "SDL_VIDEO_DRIVER_X11")

elif defined(macosx):
  switch("d", "SDL_VIDEO_DRIVER_COCOA")
