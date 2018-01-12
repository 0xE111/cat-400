 {.deadCodeElim: on.}
when defined(windows):
  const
    lib* = "enet.dll"
elif defined(macosx):
  const
    lib* = "enet.dylib"
else:
  const
    lib* = "libenet.so"
type
  ENetCallbacks* {.bycopy.} = object
    malloc*: proc (size: csize): pointer {.cdecl.}
    free*: proc (memory: pointer) {.cdecl.}
    no_memory*: proc () {.cdecl.}


proc enet_malloc*(a2: csize): pointer {.cdecl, importc: "enet_malloc", dynlib: lib.}
proc enet_free*(a2: pointer) {.cdecl, importc: "enet_free", dynlib: lib.}