# NimEnet - high-level wrapper of Enet library
import enet

# ---- types ----
type
  Host* = string
  Port* = uint16
  Address* = tuple[host: Host, port: Port]
  Server* = enet.Host
  Client* = enet.Host


# ---- stringifiers ----
proc `$`*(address: enet.Address): string =
  $address.host & ":" & $address.port

proc `$`*(host: enet.Host|Server|Client): string =
  $host.address

proc `$`*(peer: enet.Peer): string =
  $peer.address

proc `$`*(packet: ptr Packet): string =
  "[Packet of size " & $packet.dataLength & "]"
    
# ---- converters ----
# proc getAddress(host: string, port: uint16): enet.Address =
#   discard enet.address_set_host(result.addr, host.cstring)
#   result.port = port


# ---- procs ----
proc init*() =
  if enet.initialize() != 0.cint:
    raise newException(LibraryError, "An error occurred during initialization")

proc destroy*() =
  enet.deinitialize()


# ---- server ----
proc newServer*(port: Port, numConnections = 32, numChannels = 2, inBandwidth = 0, outBandwidth = 0): ptr Server =
  var address = enet.Address(host: enet.HOST_ANY, port: port)
  result = enet.host_create(
    address.addr,
    numConnections.csize,
    numChannels.csize,
    inBandwidth.uint16,
    outBandwidth.uint16
  )
  if result == nil:
    raise newException(LibraryError, "An error occured while trying to create server")

proc destroy*(self: ptr Server|Client) =
  enet.host_destroy(self)


# ---- client ----
proc newClient*(numConnections = 1, numChannels = 2, inBandwidth = 0, outBandwidth = 0): ptr Client =
  result = enet.host_create(
    nil,
    numConnections.csize,
    numChannels.csize,
    inBandwidth.uint16,
    outBandwidth.uint16
  )
  if result == nil:
    raise newException(LibraryError, "An error occured while trying to create client")

init()
var client = newClient()
client.destroy()

# proc createPacket(data: string, kind=enet.PACKET_FLAG_UNRELIABLE_FRAGMENT): ptr enet.Packet =
# var data = 
# result = enet.packet_create(data.addr, data.len.csize, kind)
