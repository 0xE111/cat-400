# Credits to https://github.com/fowlmouth/nimrod-enet/blob/master/enet.nim
{.deadCodeElim: on.}
when defined(windows):
  const lib* = "enet.dll"
elif defined(macosx):
  const lib* = "enet.dylib"
elif defined(unix):
  const lib* = "libenet.so"
else:
  {.error: "Unsupported platform"}

when defined(windows):
  import winlean
  
  type
    ENetSocket* = SOCKET
    ENetBuffer* {.bycopy.} = object
      dataLength*: csize
      data*: pointer
    ENetSocketSet* = TFdSet

  const
    ENET_SOCKET_NULL* = INVALID_SOCKET

else:
  import posix

  type
    ENetSocket* = cint
    ENetBuffer* {.bycopy.} = object
      data*: pointer
      dataLength*: csize
    ENetSocketSet* = TFdSet

  # when defined(MSG_MAXIOVLEN):
  #   const ENET_BUFFER_MAXIMUM* = MSG_MAXIOVLEN

  const
    ENET_SOCKET_NULL* = -1
    ENET_CALLBACK* = true

template ENET_HOST_TO_NET_16*(value: untyped): untyped = (htons(value))
template ENET_HOST_TO_NET_32*(value: untyped): untyped = (htonl(value))
template ENET_NET_TO_HOST_16*(value: untyped): untyped = (ntohs(value))
template ENET_NET_TO_HOST_32*(value: untyped): untyped = (ntohl(value))
template ENET_SOCKETSET_EMPTY*(sockset: untyped): untyped = FD_ZERO(addr((sockset)))
template ENET_SOCKETSET_ADD*(sockset, socket: untyped): untyped = FD_SET(socket, addr((sockset)))
template ENET_SOCKETSET_REMOVE*(sockset, socket: untyped): untyped = FD_CLR(socket, addr((sockset)))
template ENET_SOCKETSET_CHECK*(sockset, socket: untyped): untyped = FD_ISSET(socket, addr((sockset)))

template ENET_VERSION_CREATE*(major, minor, patch: untyped): untyped = (((major) shl 16) or ((minor) shl 8) or (patch))
template ENET_VERSION_GET_MAJOR*(version: untyped): untyped = (((version) shr 16) and 0x000000FF)
template ENET_VERSION_GET_MINOR*(version: untyped): untyped = (((version) shr 8) and 0x000000FF)
template ENET_VERSION_GET_PATCH*(version: untyped): untyped = ((version) and 0x000000FF)

template enet_list_begin*(list: untyped): untyped = ((list).sentinel.next)
template enet_list_end*(list: untyped): untyped = (addr((list).sentinel))
template enet_list_empty*(list: untyped): untyped = (enet_list_begin(list) == enet_list_end(list))
template enet_list_next*(`iterator`: untyped): untyped = ((`iterator`).next)
template enet_list_previous*(`iterator`: untyped): untyped = ((`iterator`).previous)
template enet_list_front*(list: untyped): untyped = (cast[pointer]((list).sentinel.next))
template enet_list_back*(list: untyped): untyped = (cast[pointer]((list).sentinel.previous))

template ENET_TIME_LESS*(a, b: untyped): untyped = ((a) - (b) >= ENET_TIME_OVERFLOW)
template ENET_TIME_GREATER*(a, b: untyped): untyped = ((b) - (a) >= ENET_TIME_OVERFLOW)
template ENET_TIME_LESS_EQUAL*(a, b: untyped): untyped = (not ENET_TIME_GREATER(a, b))
template ENET_TIME_GREATER_EQUAL*(a, b: untyped): untyped = (not ENET_TIME_LESS(a, b))
template ENET_TIME_DIFFERENCE*(a, b: untyped): untyped = (if (a) - (b) >= ENET_TIME_OVERFLOW: (b) - (a) else: (a) - (b))

template ENET_MAX*(x, y: untyped): untyped = (if (x) > (y): (x) else: (y))
template ENET_MIN*(x, y: untyped): untyped = (if (x) < (y): (x) else: (y))

const
  ENET_VERSION_MAJOR* = 1
  ENET_VERSION_MINOR* = 3
  ENET_VERSION_PATCH* = 13
  ENET_VERSION_FULL* = ENET_VERSION_CREATE(  # originally "ENET_VERSION"
    ENET_VERSION_MAJOR,
    ENET_VERSION_MINOR,
    ENET_VERSION_PATCH
  )
  ENET_HOST_ANY* = 0
  ENET_HOST_BROADCAST* = 0xFFFFFFFF
  ENET_PORT_ANY* = 0
  ENET_HOST_RECEIVE_BUFFER_SIZE* = 256 * 1024
  ENET_HOST_SEND_BUFFER_SIZE* = 256 * 1024
  ENET_HOST_BANDWIDTH_THROTTLE_INTERVAL* = 1000
  ENET_HOST_DEFAULT_MTU* = 1400
  ENET_HOST_DEFAULT_MAXIMUM_PACKET_SIZE* = 32 * 1024 * 1024
  ENET_HOST_DEFAULT_MAXIMUM_WAITING_DATA* = 32 * 1024 * 1024
  ENET_PEER_DEFAULT_ROUND_TRIP_TIME* = 500
  ENET_PEER_DEFAULT_PACKET_THROTTLE* = 32
  ENET_PEER_PACKET_THROTTLE_SCALE* = 32
  ENET_PEER_PACKET_THROTTLE_COUNTER* = 7
  ENET_PEER_PACKET_THROTTLE_ACCELERATION* = 2
  ENET_PEER_PACKET_THROTTLE_DECELERATION* = 2
  ENET_PEER_PACKET_THROTTLE_INTERVAL* = 5000
  ENET_PEER_PACKET_LOSS_SCALE* = (1 shl 16)
  ENET_PEER_PACKET_LOSS_INTERVAL* = 10000
  ENET_PEER_WINDOW_SIZE_SCALE* = 64 * 1024
  ENET_PEER_TIMEOUT_LIMIT* = 32
  ENET_PEER_TIMEOUT_MINIMUM* = 5000
  ENET_PEER_TIMEOUT_MAXIMUM* = 30000
  ENET_PEER_PING_INTERVAL* = 500
  ENET_PEER_UNSEQUENCED_WINDOWS* = 64
  ENET_PEER_UNSEQUENCED_WINDOW_SIZE* = 1024
  ENET_PEER_FREE_UNSEQUENCED_WINDOWS* = 32
  ENET_PEER_RELIABLE_WINDOWS* = 16
  ENET_PEER_RELIABLE_WINDOW_SIZE* = 0x00001000
  ENET_PEER_FREE_RELIABLE_WINDOWS* = 8
  ENET_PROTOCOL_MINIMUM_MTU* = 576
  ENET_PROTOCOL_MAXIMUM_MTU* = 4096
  ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS* = 32
  ENET_PROTOCOL_MINIMUM_WINDOW_SIZE* = 4096
  ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE* = 65536
  ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT* = 1
  ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT* = 255
  ENET_PROTOCOL_MAXIMUM_PEER_ID* = 0x00000FFF
  ENET_PROTOCOL_MAXIMUM_FRAGMENT_COUNT* = 1024 * 1024
  ENET_BUFFER_MAXIMUM = (1 + 2 * ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS)
  ENET_TIME_OVERFLOW* = 86400000

type
  enet_uint8* = cuchar
  enet_uint16* = cushort
  enet_uint32* = cuint

  ENetVersion* = enet_uint32

  # list
  ENetListNode* {.bycopy.} = object
    next*: pointer  # _ENetListNode
    previous*: pointer  # _ENetListNode

  ENetListIterator* = ptr ENetListNode
  ENetList* {.bycopy.} = object
    sentinel*: ENetListNode
  
  # protocols
  ENetProtocolCommand* = enum
    ENET_PROTOCOL_COMMAND_NONE = 0,
    ENET_PROTOCOL_COMMAND_ACKNOWLEDGE = 1,
    ENET_PROTOCOL_COMMAND_CONNECT = 2,
    ENET_PROTOCOL_COMMAND_VERIFY_CONNECT = 3,
    ENET_PROTOCOL_COMMAND_DISCONNECT = 4,
    ENET_PROTOCOL_COMMAND_PING = 5,
    ENET_PROTOCOL_COMMAND_SEND_RELIABLE = 6,
    ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE = 7,
    ENET_PROTOCOL_COMMAND_SEND_FRAGMENT = 8,
    ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED = 9,
    ENET_PROTOCOL_COMMAND_BANDWIDTH_LIMIT = 10,
    ENET_PROTOCOL_COMMAND_THROTTLE_CONFIGURE = 11,
    ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT = 12,
    ENET_PROTOCOL_COMMAND_COUNT = 13,
    ENET_PROTOCOL_COMMAND_MASK = 0x0000000F

  ENetProtocolFlag* = enum
    ENET_PROTOCOL_HEADER_SESSION_SHIFT = 12,
    ENET_PROTOCOL_COMMAND_FLAG_UNSEQUENCED = (1 shl 6),
    ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE = (1 shl 7),
    ENET_PROTOCOL_HEADER_SESSION_MASK = (3 shl 12),
    ENET_PROTOCOL_HEADER_FLAG_COMPRESSED = (1 shl 14),
    ENET_PROTOCOL_HEADER_FLAG_SENT_TIME = (1 shl 15),
    ENET_PROTOCOL_HEADER_FLAG_MASK = ENET_PROTOCOL_HEADER_FLAG_COMPRESSED.cint or ENET_PROTOCOL_HEADER_FLAG_SENT_TIME.cint

  ENetProtocolHeader* {.bycopy.} = object
    peerID*: enet_uint16
    sentTime*: enet_uint16

  ENetProtocolCommandHeader* {.bycopy.} = object
    command*: enet_uint8
    channelID*: enet_uint8
    reliableSequenceNumber*: enet_uint16

  ENetProtocolAcknowledge* {.bycopy.} = object
    header*: ENetProtocolCommandHeader
    receivedReliableSequenceNumber*: enet_uint16
    receivedSentTime*: enet_uint16

  ENetProtocolConnect* {.bycopy.} = object
    header*: ENetProtocolCommandHeader
    outgoingPeerID*: enet_uint16
    incomingSessionID*: enet_uint8
    outgoingSessionID*: enet_uint8
    mtu*: enet_uint32
    windowSize*: enet_uint32
    channelCount*: enet_uint32
    incomingBandwidth*: enet_uint32
    outgoingBandwidth*: enet_uint32
    packetThrottleInterval*: enet_uint32
    packetThrottleAcceleration*: enet_uint32
    packetThrottleDeceleration*: enet_uint32
    connectID*: enet_uint32
    data*: enet_uint32

  ENetProtocolVerifyConnect* {.bycopy.} = object
    header*: ENetProtocolCommandHeader
    outgoingPeerID*: enet_uint16
    incomingSessionID*: enet_uint8
    outgoingSessionID*: enet_uint8
    mtu*: enet_uint32
    windowSize*: enet_uint32
    channelCount*: enet_uint32
    incomingBandwidth*: enet_uint32
    outgoingBandwidth*: enet_uint32
    packetThrottleInterval*: enet_uint32
    packetThrottleAcceleration*: enet_uint32
    packetThrottleDeceleration*: enet_uint32
    connectID*: enet_uint32

  ENetProtocolBandwidthLimit* {.bycopy.} = object
    header*: ENetProtocolCommandHeader
    incomingBandwidth*: enet_uint32
    outgoingBandwidth*: enet_uint32

  ENetProtocolThrottleConfigure* {.bycopy.} = object
    header*: ENetProtocolCommandHeader
    packetThrottleInterval*: enet_uint32
    packetThrottleAcceleration*: enet_uint32
    packetThrottleDeceleration*: enet_uint32

  ENetProtocolDisconnect* {.bycopy.} = object
    header*: ENetProtocolCommandHeader
    data*: enet_uint32

  ENetProtocolPing* {.bycopy.} = object
    header*: ENetProtocolCommandHeader

  ENetProtocolSendReliable* {.bycopy.} = object
    header*: ENetProtocolCommandHeader
    dataLength*: enet_uint16

  ENetProtocolSendUnreliable* {.bycopy.} = object
    header*: ENetProtocolCommandHeader
    unreliableSequenceNumber*: enet_uint16
    dataLength*: enet_uint16

  ENetProtocolSendUnsequenced* {.bycopy.} = object
    header*: ENetProtocolCommandHeader
    unsequencedGroup*: enet_uint16
    dataLength*: enet_uint16

  ENetProtocolSendFragment* {.bycopy.} = object
    header*: ENetProtocolCommandHeader
    startSequenceNumber*: enet_uint16
    dataLength*: enet_uint16
    fragmentCount*: enet_uint32
    fragmentNumber*: enet_uint32
    totalLength*: enet_uint32
    fragmentOffset*: enet_uint32

  ENetProtocol* {.bycopy.} = object {.union.}
    header*: ENetProtocolCommandHeader
    acknowledge*: ENetProtocolAcknowledge
    connect*: ENetProtocolConnect
    verifyConnect*: ENetProtocolVerifyConnect
    disconnect*: ENetProtocolDisconnect
    ping*: ENetProtocolPing
    sendReliable*: ENetProtocolSendReliable
    sendUnreliable*: ENetProtocolSendUnreliable
    sendUnsequenced*: ENetProtocolSendUnsequenced
    sendFragment*: ENetProtocolSendFragment
    bandwidthLimit*: ENetProtocolBandwidthLimit
    throttleConfigure*: ENetProtocolThrottleConfigure

  # callbacks
  ENetCallbacks* {.bycopy.} = object
    malloc*: proc (size: csize): pointer {.cdecl.}
    free*: proc (memory: pointer) {.cdecl.}
    no_memory*: proc () {.cdecl.}

  # enet
  ENetSocketType* {.size: sizeof(cint).} = enum
    ENET_SOCKET_TYPE_STREAM = 1,
    ENET_SOCKET_TYPE_DATAGRAM = 2,
  
  ENetSocketWait* {.size: sizeof(cint).} = enum
    ENET_SOCKET_WAIT_NONE = 0,
    ENET_SOCKET_WAIT_SEND = (1 shl 0),
    ENET_SOCKET_WAIT_RECEIVE = (1 shl 1),
    ENET_SOCKET_WAIT_INTERRUPT = (1 shl 2),
  
  ENetSocketOption* {.size: sizeof(cint).} = enum
    ENET_SOCKOPT_NONBLOCK = 1,
    ENET_SOCKOPT_BROADCAST = 2,
    ENET_SOCKOPT_RCVBUF = 3,
    ENET_SOCKOPT_SNDBUF = 4,
    ENET_SOCKOPT_REUSEADDR = 5,
    ENET_SOCKOPT_RCVTIMEO = 6,
    ENET_SOCKOPT_SNDTIMEO = 7,
    ENET_SOCKOPT_ERROR = 8,
    ENET_SOCKOPT_NODELAY = 9,
  
  ENetSocketShutdown* {.size: sizeof(cint).} = enum
    ENET_SOCKET_SHUTDOWN_READ = 0,
    ENET_SOCKET_SHUTDOWN_WRITE = 1,
    ENET_SOCKET_SHUTDOWN_READ_WRITE = 2,
  
  ENetAddress* {.bycopy.} = object
    host*: enet_uint32
    port*: enet_uint16

  ENetPacketFlag* {.size: sizeof(cint).} = enum
    ENET_PACKET_FLAG_RELIABLE = (1 shl 0),
    ENET_PACKET_FLAG_UNSEQUENCED = (1 shl 1),
    ENET_PACKET_FLAG_NO_ALLOCATE = (1 shl 2),
    ENET_PACKET_FLAG_UNRELIABLE_FRAGMENT = (1 shl 3),
    ENET_PACKET_FLAG_SENT = (1 shl 8)

  ENetPacketFreeCallback* = proc (a2: pointer) {.cdecl.}  # _ENetPacket

  ENetPacket* {.bycopy.} = object
    referenceCount*: csize
    flags*: enet_uint32
    data*: ptr enet_uint8
    dataLength*: csize
    freeCallback*: ENetPacketFreeCallback
    userData*: pointer

  ENetAcknowledgement* {.bycopy.} = object
    acknowledgementList*: ENetListNode
    sentTime*: enet_uint32
    command*: ENetProtocol

  ENetOutgoingCommand* {.bycopy.} = object
    outgoingCommandList*: ENetListNode
    reliableSequenceNumber*: enet_uint16
    unreliableSequenceNumber*: enet_uint16
    sentTime*: enet_uint32
    roundTripTimeout*: enet_uint32
    roundTripTimeoutLimit*: enet_uint32
    fragmentOffset*: enet_uint32
    fragmentLength*: enet_uint16
    sendAttempts*: enet_uint16
    command*: ENetProtocol
    packet*: ptr ENetPacket

  ENetIncomingCommand* {.bycopy.} = object
    incomingCommandList*: ENetListNode
    reliableSequenceNumber*: enet_uint16
    unreliableSequenceNumber*: enet_uint16
    command*: ENetProtocol
    fragmentCount*: enet_uint32
    fragmentsRemaining*: enet_uint32
    fragments*: ptr enet_uint32
    packet*: ptr ENetPacket

  ENetPeerState* {.size: sizeof(cint).} = enum
    ENET_PEER_STATE_DISCONNECTED = 0,
    ENET_PEER_STATE_CONNECTING = 1,
    ENET_PEER_STATE_ACKNOWLEDGING_CONNECT = 2,
    ENET_PEER_STATE_CONNECTION_PENDING = 3,
    ENET_PEER_STATE_CONNECTION_SUCCEEDED = 4,
    ENET_PEER_STATE_CONNECTED = 5,
    ENET_PEER_STATE_DISCONNECT_LATER = 6,
    ENET_PEER_STATE_DISCONNECTING = 7,
    ENET_PEER_STATE_ACKNOWLEDGING_DISCONNECT = 8,
    ENET_PEER_STATE_ZOMBIE = 9

  ENetChannel* {.bycopy.} = object
    outgoingReliableSequenceNumber*: enet_uint16
    outgoingUnreliableSequenceNumber*: enet_uint16
    usedReliableWindows*: enet_uint16
    reliableWindows*: array[ENET_PEER_RELIABLE_WINDOWS, enet_uint16]
    incomingReliableSequenceNumber*: enet_uint16
    incomingUnreliableSequenceNumber*: enet_uint16
    incomingReliableCommands*: ENetList
    incomingUnreliableCommands*: ENetList

  ENetPeer* {.bycopy.} = object
    dispatchList*: ENetListNode
    host*: pointer  # _ENetHost
    outgoingPeerID*: enet_uint16
    incomingPeerID*: enet_uint16
    connectID*: enet_uint32
    outgoingSessionID*: enet_uint8
    incomingSessionID*: enet_uint8
    address*: ENetAddress
    data*: pointer
    state*: ENetPeerState
    channels*: ptr ENetChannel
    channelCount*: csize
    incomingBandwidth*: enet_uint32
    outgoingBandwidth*: enet_uint32
    incomingBandwidthThrottleEpoch*: enet_uint32
    outgoingBandwidthThrottleEpoch*: enet_uint32
    incomingDataTotal*: enet_uint32
    outgoingDataTotal*: enet_uint32
    lastSendTime*: enet_uint32
    lastReceiveTime*: enet_uint32
    nextTimeout*: enet_uint32
    earliestTimeout*: enet_uint32
    packetLossEpoch*: enet_uint32
    packetsSent*: enet_uint32
    packetsLost*: enet_uint32
    packetLoss*: enet_uint32
    packetLossVariance*: enet_uint32
    packetThrottle*: enet_uint32
    packetThrottleLimit*: enet_uint32
    packetThrottleCounter*: enet_uint32
    packetThrottleEpoch*: enet_uint32
    packetThrottleAcceleration*: enet_uint32
    packetThrottleDeceleration*: enet_uint32
    packetThrottleInterval*: enet_uint32
    pingInterval*: enet_uint32
    timeoutLimit*: enet_uint32
    timeoutMinimum*: enet_uint32
    timeoutMaximum*: enet_uint32
    lastRoundTripTime*: enet_uint32
    lowestRoundTripTime*: enet_uint32
    lastRoundTripTimeVariance*: enet_uint32
    highestRoundTripTimeVariance*: enet_uint32
    roundTripTime*: enet_uint32
    roundTripTimeVariance*: enet_uint32
    mtu*: enet_uint32
    windowSize*: enet_uint32
    reliableDataInTransit*: enet_uint32
    outgoingReliableSequenceNumber*: enet_uint16
    acknowledgements*: ENetList
    sentReliableCommands*: ENetList
    sentUnreliableCommands*: ENetList
    outgoingReliableCommands*: ENetList
    outgoingUnreliableCommands*: ENetList
    dispatchedCommands*: ENetList
    needsDispatch*: cint
    incomingUnsequencedGroup*: enet_uint16
    outgoingUnsequencedGroup*: enet_uint16
    unsequencedWindow*: array[ENET_PEER_UNSEQUENCED_WINDOW_SIZE div 32, enet_uint32]
    eventData*: enet_uint32
    totalWaitingData*: csize

  ENetCompressor* {.bycopy.} = object
    context*: pointer
    compress*: proc (context: pointer; inBuffers: ptr ENetBuffer; inBufferCount: csize; inLimit: csize; outData: ptr enet_uint8; outLimit: csize): csize {.cdecl.}
    decompress*: proc (context: pointer; inData: ptr enet_uint8; inLimit: csize; outData: ptr enet_uint8; outLimit: csize): csize {.cdecl.}
    destroy*: proc (context: pointer) {.cdecl.}

  ENetChecksumCallback* = proc (buffers: ptr ENetBuffer; bufferCount: csize): enet_uint32 {.cdecl.}

  ENetInterceptCallback* = proc (host: pointer; event: pointer): cint {.cdecl.}  # _ENetHost, _ENetEvent

  ENetHost* {.bycopy.} = object
    socket*: ENetSocket
    address*: ENetAddress
    incomingBandwidth*: enet_uint32
    outgoingBandwidth*: enet_uint32
    bandwidthThrottleEpoch*: enet_uint32
    mtu*: enet_uint32
    randomSeed*: enet_uint32
    recalculateBandwidthLimits*: cint
    peers*: ptr ENetPeer
    peerCount*: csize
    channelLimit*: csize
    serviceTime*: enet_uint32
    dispatchQueue*: ENetList
    continueSending*: cint
    packetSize*: csize
    headerFlags*: enet_uint16
    commands*: array[ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS, ENetProtocol]
    commandCount*: csize
    buffers*: array[ENET_BUFFER_MAXIMUM, ENetBuffer]
    bufferCount*: csize
    checksum*: ENetChecksumCallback
    compressor*: ENetCompressor
    packetData*: array[2, array[ENET_PROTOCOL_MAXIMUM_MTU, enet_uint8]]
    receivedAddress*: ENetAddress
    receivedData*: ptr enet_uint8
    receivedDataLength*: csize
    totalSentData*: enet_uint32
    totalSentPackets*: enet_uint32
    totalReceivedData*: enet_uint32
    totalReceivedPackets*: enet_uint32
    intercept*: ENetInterceptCallback
    connectedPeers*: csize
    bandwidthLimitedPeers*: csize
    duplicatePeers*: csize
    maximumPacketSize*: csize
    maximumWaitingData*: csize

  ENetEventType* {.size: sizeof(cint).} = enum
    ENET_EVENT_TYPE_NONE = 0, ENET_EVENT_TYPE_CONNECT = 1,
    ENET_EVENT_TYPE_DISCONNECT = 2, ENET_EVENT_TYPE_RECEIVE = 3

  ENetEvent* {.bycopy.} = object
    `type`*: ENetEventType
    peer*: ptr ENetPeer
    channelID*: enet_uint8
    data*: enet_uint32
    packet*: ptr ENetPacket

{.push cdecl, dynlib:lib, importc:"enet_$1".}
proc initialize*(): cint
proc initialize_with_callbacks*(version: ENetVersion; inits: ptr ENetCallbacks): cint
proc deinitialize*()
proc linked_version*(): ENetVersion
proc time_get*(): enet_uint32
proc time_set*(a2: enet_uint32)
proc socket_create*(a2: ENetSocketType): ENetSocket
proc socket_bind*(a2: ENetSocket; a3: ptr ENetAddress): cint
proc socket_get_address*(a2: ENetSocket; a3: ptr ENetAddress): cint  
proc socket_listen*(a2: ENetSocket; a3: cint): cint  
proc socket_accept*(a2: ENetSocket; a3: ptr ENetAddress): ENetSocket  
proc socket_connect*(a2: ENetSocket; a3: ptr ENetAddress): cint  
proc socket_send*(a2: ENetSocket; a3: ptr ENetAddress; a4: ptr ENetBuffer; a5: csize): cint  
proc socket_receive*(a2: ENetSocket; a3: ptr ENetAddress; a4: ptr ENetBuffer; a5: csize): cint  
proc socket_wait*(a2: ENetSocket; a3: ptr enet_uint32; a4: enet_uint32): cint  
proc socket_set_option*(a2: ENetSocket; a3: ENetSocketOption; a4: cint): cint  
proc socket_get_option*(a2: ENetSocket; a3: ENetSocketOption; a4: ptr cint): cint  
proc socket_shutdown*(a2: ENetSocket; a3: ENetSocketShutdown): cint  
proc socket_destroy*(a2: ENetSocket)  
proc socketset_select*(a2: ENetSocket; a3: ptr ENetSocketSet; a4: ptr ENetSocketSet; a5: enet_uint32): cint  
proc address_set_host*(address: ptr ENetAddress; hostName: cstring): cint  
proc address_get_host_ip*(address: ptr ENetAddress; hostName: cstring; nameLength: csize): cint  
proc address_get_host*(address: ptr ENetAddress; hostName: cstring; nameLength: csize): cint  
proc packet_create*(a2: pointer; a3: csize; a4: enet_uint32): ptr ENetPacket  
proc packet_destroy*(a2: ptr ENetPacket)
proc packet_resize*(a2: ptr ENetPacket; a3: csize): cint
proc crc32*(a2: ptr ENetBuffer; a3: csize): enet_uint32
proc host_create*(a2: ptr ENetAddress; a3: csize; a4: csize; a5: enet_uint32; a6: enet_uint32): ptr ENetHost
proc host_destroy*(a2: ptr ENetHost)
proc host_connect*(a2: ptr ENetHost; a3: ptr ENetAddress; a4: csize; a5: enet_uint32): ptr ENetPeer  
proc host_check_events*(a2: ptr ENetHost; a3: ptr ENetEvent): cint
proc host_service*(a2: ptr ENetHost; a3: ptr ENetEvent; a4: enet_uint32): cint  
proc host_flush*(a2: ptr ENetHost)
proc host_broadcast*(a2: ptr ENetHost; a3: enet_uint8; a4: ptr ENetPacket)
proc host_compress*(a2: ptr ENetHost; a3: ptr ENetCompressor)
proc host_compress_with_range_coder*(host: ptr ENetHost): cint
proc host_channel_limit*(a2: ptr ENetHost; a3: csize)
proc host_bandwidth_limit*(a2: ptr ENetHost; a3: enet_uint32; a4: enet_uint32)  
proc host_bandwidth_throttle*(a2: ptr ENetHost)
proc host_random_seed*(): enet_uint32
proc peer_send*(a2: ptr ENetPeer; a3: enet_uint8; a4: ptr ENetPacket): cint
proc peer_receive*(a2: ptr ENetPeer; channelID: ptr enet_uint8): ptr ENetPacket  
proc peer_ping*(a2: ptr ENetPeer)  
proc peer_ping_interval*(a2: ptr ENetPeer; a3: enet_uint32)
proc peer_timeout*(a2: ptr ENetPeer; a3: enet_uint32; a4: enet_uint32; a5: enet_uint32)
proc peer_reset*(a2: ptr ENetPeer)
proc peer_disconnect*(a2: ptr ENetPeer; a3: enet_uint32)
proc peer_disconnect_now*(a2: ptr ENetPeer; a3: enet_uint32)
proc peer_disconnect_later*(a2: ptr ENetPeer; a3: enet_uint32)
proc peer_throttle_configure*(a2: ptr ENetPeer; a3: enet_uint32; a4: enet_uint32; a5: enet_uint32)
proc peer_throttle*(a2: ptr ENetPeer; a3: enet_uint32): cint
proc peer_reset_queues*(a2: ptr ENetPeer)
proc peer_setup_outgoing_command*(a2: ptr ENetPeer; a3: ptr ENetOutgoingCommand)  
proc peer_queue_outgoing_command*(a2: ptr ENetPeer; a3: ptr ENetProtocol; a4: ptr ENetPacket; a5: enet_uint32; a6: enet_uint16): ptr ENetOutgoingCommand  
proc peer_queue_incoming_command*(a2: ptr ENetPeer; a3: ptr ENetProtocol; a4: pointer; a5: csize; a6: enet_uint32; a7: enet_uint32): ptr ENetIncomingCommand  
proc peer_queue_acknowledgement*(a2: ptr ENetPeer; a3: ptr ENetProtocol; a4: enet_uint16): ptr ENetAcknowledgement
proc peer_dispatch_incoming_unreliable_commands*(a2: ptr ENetPeer; a3: ptr ENetChannel)
proc peer_dispatch_incoming_reliable_commands*(a2: ptr ENetPeer; a3: ptr ENetChannel)
proc peer_on_connect*(a2: ptr ENetPeer)
proc peer_on_disconnect*(a2: ptr ENetPeer)
proc range_coder_create*(): pointer
proc range_coder_destroy*(a2: pointer)
proc range_coder_compress*(a2: pointer; a3: ptr ENetBuffer; a4: csize; a5: csize; a6: ptr enet_uint8; a7: csize): csize
proc range_coder_decompress*(a2: pointer; a3: ptr enet_uint8; a4: csize; a5: ptr enet_uint8; a6: csize): csize
proc protocol_command_size*(a2: enet_uint8): csize

# list
proc list_clear*(a2: ptr ENetList)  
proc list_insert*(a2: ENetListIterator; a3: pointer): ENetListIterator  
proc list_remove*(a2: ENetListIterator): pointer  
proc list_move*(a2: ENetListIterator; a3: pointer; a4: pointer): ENetListIterator
proc list_size*(a2: ptr ENetList): csize  

proc malloc*(a2: csize): pointer  
proc free*(a2: pointer)  
{.pop.}
