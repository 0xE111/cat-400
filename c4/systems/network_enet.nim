import logging
import network
import ../wrappers/enet/[
  enet,
]


template debug(message: string) =
  logging.debug("Enet network: " & message)


type
  EnetNetwork* = object of Network
    host: ptr enet.Host
    case kind: NetworkKind
      of nkClient:
        server: enet.Address
      else:
        nil


# ==== helpers ====
proc createHost(address: ptr enet.Address, numClients = 32, numChannels = 2, inBandwidth = 0, outBandwidth = 0): ptr enet.Host =
  result = enet.host_create(address, numClients.csize, numChannels.csize, inBandwidth.uint32, outBandwidth.uint32)
  if result == nil:
    let err = "An error occured while trying to create a server"
    debug(err)
    raise newException(LibraryError, err)

proc `$`*(host: ptr enet.Host): string =
  $host.address.host & ":" & $host.address.port


# ==== implementation ====
method init*(self: ref EnetNetwork, kind: NetworkKind, port = enet.PORT_ANY) =
  if enet.initialize() != 0.cint:
    let err = "An error occurred during initialization"
    debug(err)
    raise newException(LibraryError, err)
  debug("Initialization successful")

  if kind == nkServer:
    var address = enet.Address(host: enet.HOST_ANY, port: port)
    self.host = createHost(addr(address))
    debug("Server started: " & $self.host)
  else:
    self.host = createHost(nil, numClients=1.csize)
    debug("Client started: " & $self.host)

method destroy*(self: ref EnetNetwork) =
  enet.deinitialize()
  debug("Deinitialization successful")

method update*(self: ref EnetNetwork, dt: float): bool =
  result = true
