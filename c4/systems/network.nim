type
  Host = string
  Port = uint16
  Address = tuple[
    host: Host,
    port: Port,
  ]
  NetworkKind* = enum
    nkServer, nkClient

  Network* = object {.inheritable.}


method init*(self: ref Network, kind: NetworkKind, port: Port = 0) {.base.} =
  doAssert(false, "Not implemented")

method connect*(self: ref Network, address: Address) {.base.} =
  doAssert(false, "Not implemented")

method update*(self: ref Network, dt: float): bool {.base.} =
  doAssert(false, "Not implemented")

method destroy*(self: ref Network) {.base.} =
  doAssert(false, "Not implemented")
