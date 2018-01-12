when defined(_MSC_VER):
  when defined(ENET_BUILDING_LIB):
type
  ENetSocket* = SOCKET

const
  ENET_SOCKET_NULL* = INVALID_SOCKET

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
    dataLength*: csize
    data*: pointer


# when defined(ENET_DLL):
#   when defined(ENET_BUILDING_LIB):
#     const
#       ENET_API* = __declspec(dllexport)
#   else:
#     const
#       ENET_API* = __declspec(dllimport)
# else:
#   const
#     ENET_API* = extern
type
  ENetSocketSet* = fd_set

template ENET_SOCKETSET_EMPTY*(sockset: untyped): untyped =
  FD_ZERO(addr((sockset)))

template ENET_SOCKETSET_ADD*(sockset, socket: untyped): untyped =
  FD_SET(socket, addr((sockset)))

template ENET_SOCKETSET_REMOVE*(sockset, socket: untyped): untyped =
  FD_CLR(socket, addr((sockset)))

template ENET_SOCKETSET_CHECK*(sockset, socket: untyped): untyped =
  FD_ISSET(socket, addr((sockset)))
