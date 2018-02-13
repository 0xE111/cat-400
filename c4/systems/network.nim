from ../utils/helpers import notImplemented
type
  Host = string
  Port = uint16
  Address = tuple[
    host: Host,
    port: Port,
  ]

  ServerNetwork* = object {.inheritable.}
  ClientNetwork* = object {.inheritable.}


# ---- Server interface ----
method init*(self: ref ServerNetwork, port: Port = 0) {.base.} = notImplemented()
method update*(self: ref ServerNetwork, dt: float): bool {.base.} = notImplemented()
method destroy*(self: ref ServerNetwork) {.base.} = notImplemented()

# ---- Client interface ----
method init*(self: ref ClientNetwork) {.base.} = notImplemented()
method connect*(self: ref ClientNetwork, address: Address) {.base.} = notImplemented()
method update*(self: ref ClientNetwork, dt: float): bool {.base.} = notImplemented()
method destroy*(self: ref ClientNetwork) {.base.} = notImplemented()
