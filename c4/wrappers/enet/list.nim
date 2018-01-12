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
  ENetListNode* {.bycopy.} = object
    next*: ptr _ENetListNode
    previous*: ptr _ENetListNode

  ENetListIterator* = ptr ENetListNode
  ENetList* {.bycopy.} = object
    sentinel*: ENetListNode


proc enet_list_clear*(a2: ptr ENetList) {.cdecl, importc: "enet_list_clear",
                                      dynlib: lib.}
proc enet_list_insert*(a2: ENetListIterator; a3: pointer): ENetListIterator {.cdecl,
    importc: "enet_list_insert", dynlib: lib.}
proc enet_list_remove*(a2: ENetListIterator): pointer {.cdecl,
    importc: "enet_list_remove", dynlib: lib.}
proc enet_list_move*(a2: ENetListIterator; a3: pointer; a4: pointer): ENetListIterator {.
    cdecl, importc: "enet_list_move", dynlib: lib.}
proc enet_list_size*(a2: ptr ENetList): csize {.cdecl, importc: "enet_list_size",
    dynlib: lib.}
template enet_list_begin*(list: untyped): untyped =
  ((list).sentinel.next)

template enet_list_end*(list: untyped): untyped =
  (addr((list).sentinel))

template enet_list_empty*(list: untyped): untyped =
  (enet_list_begin(list) == enet_list_end(list))

template enet_list_next*(`iterator`: untyped): untyped =
  ((`iterator`).next)

template enet_list_previous*(`iterator`: untyped): untyped =
  ((`iterator`).previous)

template enet_list_front*(list: untyped): untyped =
  (cast[pointer]((list).sentinel.next))

template enet_list_back*(list: untyped): untyped =
  (cast[pointer]((list).sentinel.previous))
