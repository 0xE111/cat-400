type
  NetworkSystemKind* {.pure.} = enum
    Server, Client

  NetworkSystem* = object of RootObj


method init*(self: ref NetworkSystem, kind: NetworkSystemKind) {.base.} =
  doAssert(false, "Not implemented")

method update*(self: ref NetworkSystem, dt: float): bool {.base.} =
  doAssert(false, "Not implemented")
