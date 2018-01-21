# A high-level nim-style Enet library wrapper
from ./enet import nil
from logging import nil

template debug(message: string) =
  logging.debug("NimEnet: " & message)


proc init*() =
  if enet.initialize() != 0.cint:
    debug("An error occurred during initialization")
    raise newException(LibraryError, "An error occurred during initialization")
  debug("Initialization successful")

proc deinit*() =
  enet.deinitialize()
  debug("Deinitialization successful")

proc startServer*(host = enet.HOST_ANY, port = enet.PORT_ANY, numClients = 32, numChannels = 2, inBandwidth = 0, outBandwidth = 0): ptr enet.Host =
  var address = enet.Address(host: host, port: port)
  result = enet.host_create(addr(address), numClients.csize, numChannels.csize, inBandwidth.uint32, outBandwidth.uint32)

proc `$`*(host: ptr enet.Host): string = $host.address.host & ":" & $host.address.port
