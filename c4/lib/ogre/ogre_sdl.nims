
when defined(windows):
  switch("d", "SDL_VIDEO_DRIVER_WINDOWS")

elif defined(linux):
  switch("d", "SDL_VIDEO_DRIVER_X11")

elif defined(macosx):
  switch("d", "SDL_VIDEO_DRIVER_COCOA")

else:
  raise newException(LibraryError, "Your system is not supported")
