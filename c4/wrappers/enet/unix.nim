when defined(MSG_MAXIOVLEN):
  const
    ENET_BUFFER_MAXIMUM* = MSG_MAXIOVLEN
type
  ENetSocket* = cint

const
  ENET_SOCKET_NULL* = -1

template ENET_HOST_TO_NET_16*(value: untyped): untyped =
  (htons(value))

template ENET_HOST_TO_NET_32*(value: untyped): untyped =
  (htonl(value))

template ENET_NET_TO_HOST_16*(value: untyped): untyped =
  (ntohs(value))

template ENET_NET_TO_HOST_32*(value: untyped): untyped =
  (ntohl(value))

type
  ENetBuffer* {.bycopy.} = object
    data*: pointer
    dataLength*: csize


const
  ENET_CALLBACK* = true

when defined(windows):
  import winlean
else:
  import posix

type
  ENetSocketSet* = TFdSet

template ENET_SOCKETSET_EMPTY*(sockset: untyped): untyped =
  FD_ZERO(addr((sockset)))

template ENET_SOCKETSET_ADD*(sockset, socket: untyped): untyped =
  FD_SET(socket, addr((sockset)))

template ENET_SOCKETSET_REMOVE*(sockset, socket: untyped): untyped =
  FD_CLR(socket, addr((sockset)))

template ENET_SOCKETSET_CHECK*(sockset, socket: untyped): untyped =
  FD_ISSET(socket, addr((sockset)))
