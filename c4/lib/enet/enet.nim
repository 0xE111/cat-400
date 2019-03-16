# Credits to https://github.com/fowlmouth/nimrod-enet/blob/master/enet.nim
{.deadCodeElim: on.}
when defined(windows):
  const lib* = "enet.dll"
elif defined(macosx):
  const lib* = "enet.dylib"
elif defined(unix):
  const lib* = "libenet.so"
else:
  {.error: "Unsupported platform".}

when defined(windows):
  import winlean
  
  type
    Socket* = SOCKET
    Buffer* {.bycopy.} = object
      dataLength*: csize
      data*: pointer
    SocketSet* = TFdSet

  const
    SOCKET_NULL* = INVALID_SOCKET

else:
  import posix

  type
    Socket* = cint
    Buffer* {.bycopy.} = object
      data*: pointer
      dataLength*: csize
    SocketSet* = TFdSet

  # when defined(MSG_MAXIOVLEN):
  #   const BUFFER_MAXIMUM* = MSG_MAXIOVLEN

  const
    SOCKET_NULL* = -1
    CALLBACK* = true

template HOST_TO_NET_16*(value: untyped): untyped = (htons(value))
template HOST_TO_NET_32*(value: untyped): untyped = (htonl(value))
template NET_TO_HOST_16*(value: untyped): untyped = (ntohs(value))
template NET_TO_HOST_32*(value: untyped): untyped = (ntohl(value))
template SOCKETSET_EMPTY*(sockset: untyped): untyped = FD_ZERO(addr((sockset)))
template SOCKETSET_ADD*(sockset, socket: untyped): untyped = FD_SET(socket, addr((sockset)))
template SOCKETSET_REMOVE*(sockset, socket: untyped): untyped = FD_CLR(socket, addr((sockset)))
template SOCKETSET_CHECK*(sockset, socket: untyped): untyped = FD_ISSET(socket, addr((sockset)))

template VERSION_CREATE*(major, minor, patch: untyped): untyped = (((major) shl 16) or ((minor) shl 8) or (patch))
template VERSION_GET_MAJOR*(version: untyped): untyped = (((version) shr 16) and 0x000000FF)
template VERSION_GET_MINOR*(version: untyped): untyped = (((version) shr 8) and 0x000000FF)
template VERSION_GET_PATCH*(version: untyped): untyped = ((version) and 0x000000FF)

template list_begin*(list: untyped): untyped = ((list).sentinel.next)
template list_end*(list: untyped): untyped = (addr((list).sentinel))
template list_empty*(list: untyped): untyped = (list_begin(list) == list_end(list))
template list_next*(`iterator`: untyped): untyped = ((`iterator`).next)
template list_previous*(`iterator`: untyped): untyped = ((`iterator`).previous)
template list_front*(list: untyped): untyped = (cast[pointer]((list).sentinel.next))
template list_back*(list: untyped): untyped = (cast[pointer]((list).sentinel.previous))

template TIME_LESS*(a, b: untyped): untyped = ((a) - (b) >= TIME_OVERFLOW)
template TIME_GREATER*(a, b: untyped): untyped = ((b) - (a) >= TIME_OVERFLOW)
template TIME_LESS_EQUAL*(a, b: untyped): untyped = (not TIME_GREATER(a, b))
template TIME_GREATER_EQUAL*(a, b: untyped): untyped = (not TIME_LESS(a, b))
template TIME_DIFFERENCE*(a, b: untyped): untyped = (if (a) - (b) >= TIME_OVERFLOW: (b) - (a) else: (a) - (b))

template MAX*(x, y: untyped): untyped = (if (x) > (y): (x) else: (y))
template MIN*(x, y: untyped): untyped = (if (x) < (y): (x) else: (y))

const
  VERSION_MAJOR* = 1
  VERSION_MINOR* = 3
  VERSION_PATCH* = 13
  VERSION_FULL* = VERSION_CREATE(  # originally "VERSION"
    VERSION_MAJOR,
    VERSION_MINOR,
    VERSION_PATCH
  )
  HOST_ANY* = 0'u32
  HOST_BROADCAST* = 0xFFFFFFFF
  PORT_ANY* = 0'u16
  HOST_RECEIVE_BUFFER_SIZE* = 256 * 1024
  HOST_SEND_BUFFER_SIZE* = 256 * 1024
  HOST_BANDWIDTH_THROTTLE_INTERVAL* = 1000
  HOST_DEFAULT_MTU* = 1400
  HOST_DEFAULT_MAXIMUM_PACKET_SIZE* = 32 * 1024 * 1024
  HOST_DEFAULT_MAXIMUM_WAITING_DATA* = 32 * 1024 * 1024
  PEER_DEFAULT_ROUND_TRIP_TIME* = 500
  PEER_DEFAULT_PACKET_THROTTLE* = 32
  PEER_PACKET_THROTTLE_SCALE* = 32
  PEER_PACKET_THROTTLE_COUNTER* = 7
  PEER_PACKET_THROTTLE_ACCELERATION* = 2
  PEER_PACKET_THROTTLE_DECELERATION* = 2
  PEER_PACKET_THROTTLE_INTERVAL* = 5000
  PEER_PACKET_LOSS_SCALE* = (1 shl 16)
  PEER_PACKET_LOSS_INTERVAL* = 10000
  PEER_WINDOW_SIZE_SCALE* = 64 * 1024
  PEER_TIMEOUT_LIMIT* = 32
  PEER_TIMEOUT_MINIMUM* = 5000
  PEER_TIMEOUT_MAXIMUM* = 30000
  PEER_PING_INTERVAL* = 500
  PEER_UNSEQUENCED_WINDOWS* = 64
  PEER_UNSEQUENCED_WINDOW_SIZE* = 1024
  PEER_FREE_UNSEQUENCED_WINDOWS* = 32
  PEER_RELIABLE_WINDOWS* = 16
  PEER_RELIABLE_WINDOW_SIZE* = 0x00001000
  PEER_FREE_RELIABLE_WINDOWS* = 8
  PROTOCOL_MINIMUM_MTU* = 576
  PROTOCOL_MAXIMUM_MTU* = 4096
  PROTOCOL_MAXIMUM_PACKET_COMMANDS* = 32
  PROTOCOL_MINIMUM_WINDOW_SIZE* = 4096
  PROTOCOL_MAXIMUM_WINDOW_SIZE* = 65536
  PROTOCOL_MINIMUM_CHANNEL_COUNT* = 1
  PROTOCOL_MAXIMUM_CHANNEL_COUNT* = 255
  PROTOCOL_MAXIMUM_PEER_ID* = 0x00000FFF
  PROTOCOL_MAXIMUM_FRAGMENT_COUNT* = 1024 * 1024
  BUFFER_MAXIMUM* = (1 + 2 * PROTOCOL_MAXIMUM_PACKET_COMMANDS)
  TIME_OVERFLOW* = 86400000

type
  # uint8* = cuchar
  # uint16* = cushort
  # uint32* = cuint

  Version* = uint32

  # list
  ListNode* {.bycopy.} = object
    next*: pointer  # _ListNode
    previous*: pointer  # _ListNode

  ListIterator* = ptr ListNode
  List* {.bycopy.} = object
    sentinel*: ListNode
  
  # protocols
  ProtocolCommand* = enum
    PROTOCOL_COMMAND_NONE = 0,
    PROTOCOL_COMMAND_ACKNOWLEDGE = 1,
    PROTOCOL_COMMAND_CONNECT = 2,
    PROTOCOL_COMMAND_VERIFY_CONNECT = 3,
    PROTOCOL_COMMAND_DISCONNECT = 4,
    PROTOCOL_COMMAND_PING = 5,
    PROTOCOL_COMMAND_SEND_RELIABLE = 6,
    PROTOCOL_COMMAND_SEND_UNRELIABLE = 7,
    PROTOCOL_COMMAND_SEND_FRAGMENT = 8,
    PROTOCOL_COMMAND_SEND_UNSEQUENCED = 9,
    PROTOCOL_COMMAND_BANDWIDTH_LIMIT = 10,
    PROTOCOL_COMMAND_THROTTLE_CONFIGURE = 11,
    PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT = 12,
    PROTOCOL_COMMAND_COUNT = 13,
    PROTOCOL_COMMAND_MASK = 0x0000000F

  ProtocolFlag* = enum
    PROTOCOL_HEADER_SESSION_SHIFT = 12,
    PROTOCOL_COMMAND_FLAG_UNSEQUENCED = (1 shl 6),
    PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE = (1 shl 7),
    PROTOCOL_HEADER_SESSION_MASK = (3 shl 12),
    PROTOCOL_HEADER_FLAG_COMPRESSED = (1 shl 14),
    PROTOCOL_HEADER_FLAG_SENT_TIME = (1 shl 15),
    PROTOCOL_HEADER_FLAG_MASK = PROTOCOL_HEADER_FLAG_COMPRESSED.cint or PROTOCOL_HEADER_FLAG_SENT_TIME.cint

  ProtocolHeader* {.bycopy.} = object
    peerID*: uint16
    sentTime*: uint16

  ProtocolCommandHeader* {.bycopy.} = object
    command*: uint8
    channelID*: uint8
    reliableSequenceNumber*: uint16

  ProtocolAcknowledge* {.bycopy.} = object
    header*: ProtocolCommandHeader
    receivedReliableSequenceNumber*: uint16
    receivedSentTime*: uint16

  ProtocolConnect* {.bycopy.} = object
    header*: ProtocolCommandHeader
    outgoingPeerID*: uint16
    incomingSessionID*: uint8
    outgoingSessionID*: uint8
    mtu*: uint32
    windowSize*: uint32
    channelCount*: uint32
    incomingBandwidth*: uint32
    outgoingBandwidth*: uint32
    packetThrottleInterval*: uint32
    packetThrottleAcceleration*: uint32
    packetThrottleDeceleration*: uint32
    connectID*: uint32
    data*: uint32

  ProtocolVerifyConnect* {.bycopy.} = object
    header*: ProtocolCommandHeader
    outgoingPeerID*: uint16
    incomingSessionID*: uint8
    outgoingSessionID*: uint8
    mtu*: uint32
    windowSize*: uint32
    channelCount*: uint32
    incomingBandwidth*: uint32
    outgoingBandwidth*: uint32
    packetThrottleInterval*: uint32
    packetThrottleAcceleration*: uint32
    packetThrottleDeceleration*: uint32
    connectID*: uint32

  ProtocolBandwidthLimit* {.bycopy.} = object
    header*: ProtocolCommandHeader
    incomingBandwidth*: uint32
    outgoingBandwidth*: uint32

  ProtocolThrottleConfigure* {.bycopy.} = object
    header*: ProtocolCommandHeader
    packetThrottleInterval*: uint32
    packetThrottleAcceleration*: uint32
    packetThrottleDeceleration*: uint32

  ProtocolDisconnect* {.bycopy.} = object
    header*: ProtocolCommandHeader
    data*: uint32

  ProtocolPing* {.bycopy.} = object
    header*: ProtocolCommandHeader

  ProtocolSendReliable* {.bycopy.} = object
    header*: ProtocolCommandHeader
    dataLength*: uint16

  ProtocolSendUnreliable* {.bycopy.} = object
    header*: ProtocolCommandHeader
    unreliableSequenceNumber*: uint16
    dataLength*: uint16

  ProtocolSendUnsequenced* {.bycopy.} = object
    header*: ProtocolCommandHeader
    unsequencedGroup*: uint16
    dataLength*: uint16

  ProtocolSendFragment* {.bycopy.} = object
    header*: ProtocolCommandHeader
    startSequenceNumber*: uint16
    dataLength*: uint16
    fragmentCount*: uint32
    fragmentNumber*: uint32
    totalLength*: uint32
    fragmentOffset*: uint32

  Protocol* {.bycopy.} = object {.union.}
    header*: ProtocolCommandHeader
    acknowledge*: ProtocolAcknowledge
    connect*: ProtocolConnect
    verifyConnect*: ProtocolVerifyConnect
    disconnect*: ProtocolDisconnect
    ping*: ProtocolPing
    sendReliable*: ProtocolSendReliable
    sendUnreliable*: ProtocolSendUnreliable
    sendUnsequenced*: ProtocolSendUnsequenced
    sendFragment*: ProtocolSendFragment
    bandwidthLimit*: ProtocolBandwidthLimit
    throttleConfigure*: ProtocolThrottleConfigure

  # callbacks
  Callbacks* {.bycopy.} = object
    malloc*: proc (size: csize): pointer {.cdecl.}
    free*: proc (memory: pointer) {.cdecl.}
    no_memory*: proc () {.cdecl.}

  # base
  SocketType* {.size: sizeof(cint).} = enum
    SOCKET_TYPE_STREAM = 1,
    SOCKET_TYPE_DATAGRAM = 2,
  
  SocketWait* {.size: sizeof(cint).} = enum
    SOCKET_WAIT_NONE = 0,
    SOCKET_WAIT_SEND = (1 shl 0),
    SOCKET_WAIT_RECEIVE = (1 shl 1),
    SOCKET_WAIT_INTERRUPT = (1 shl 2),
  
  SocketOption* {.size: sizeof(cint).} = enum
    SOCKOPT_NONBLOCK = 1,
    SOCKOPT_BROADCAST = 2,
    SOCKOPT_RCVBUF = 3,
    SOCKOPT_SNDBUF = 4,
    SOCKOPT_REUSEADDR = 5,
    SOCKOPT_RCVTIMEO = 6,
    SOCKOPT_SNDTIMEO = 7,
    SOCKOPT_ERROR = 8,
    SOCKOPT_NODELAY = 9,
  
  SocketShutdown* {.size: sizeof(cint).} = enum
    SOCKET_SHUTDOWN_READ = 0,
    SOCKET_SHUTDOWN_WRITE = 1,
    SOCKET_SHUTDOWN_READ_WRITE = 2,
  
  Address* {.bycopy.} = object
    host*: uint32
    port*: uint16

  PacketFlag* {.size: sizeof(cint).} = enum
    PACKET_FLAG_UNRELIABLE = 0,
    PACKET_FLAG_RELIABLE = (1 shl 0),
    PACKET_FLAG_UNSEQUENCED = (1 shl 1),
    PACKET_FLAG_NO_ALLOCATE = (1 shl 2),
    PACKET_FLAG_UNRELIABLE_FRAGMENT = (1 shl 3),
    PACKET_FLAG_SENT = (1 shl 8)

  PacketFreeCallback* = proc (a2: pointer) {.cdecl.}  # _Packet

  Packet* {.bycopy.} = object
    referenceCount*: csize
    flags*: uint32
    data*: ptr uint8
    dataLength*: csize
    freeCallback*: PacketFreeCallback
    userData*: pointer

  Acknowledgement* {.bycopy.} = object
    acknowledgementList*: ListNode
    sentTime*: uint32
    command*: Protocol

  OutgoingCommand* {.bycopy.} = object
    outgoingCommandList*: ListNode
    reliableSequenceNumber*: uint16
    unreliableSequenceNumber*: uint16
    sentTime*: uint32
    roundTripTimeout*: uint32
    roundTripTimeoutLimit*: uint32
    fragmentOffset*: uint32
    fragmentLength*: uint16
    sendAttempts*: uint16
    command*: Protocol
    packet*: ptr Packet

  IncomingCommand* {.bycopy.} = object
    incomingCommandList*: ListNode
    reliableSequenceNumber*: uint16
    unreliableSequenceNumber*: uint16
    command*: Protocol
    fragmentCount*: uint32
    fragmentsRemaining*: uint32
    fragments*: ptr uint32
    packet*: ptr Packet

  PeerState* {.size: sizeof(cint).} = enum
    PEER_STATE_DISCONNECTED = 0,
    PEER_STATE_CONNECTING = 1,
    PEER_STATE_ACKNOWLEDGING_CONNECT = 2,
    PEER_STATE_CONNECTION_PENDING = 3,
    PEER_STATE_CONNECTION_SUCCEEDED = 4,
    PEER_STATE_CONNECTED = 5,
    PEER_STATE_DISCONNECT_LATER = 6,
    PEER_STATE_DISCONNECTING = 7,
    PEER_STATE_ACKNOWLEDGING_DISCONNECT = 8,
    PEER_STATE_ZOMBIE = 9

  Channel* {.bycopy.} = object
    outgoingReliableSequenceNumber*: uint16
    outgoingUnreliableSequenceNumber*: uint16
    usedReliableWindows*: uint16
    reliableWindows*: array[PEER_RELIABLE_WINDOWS, uint16]
    incomingReliableSequenceNumber*: uint16
    incomingUnreliableSequenceNumber*: uint16
    incomingReliableCommands*: List
    incomingUnreliableCommands*: List

  Peer* {.bycopy.} = object
    dispatchList*: ListNode
    host*: pointer  # _Host
    outgoingPeerID*: uint16
    incomingPeerID*: uint16
    connectID*: uint32
    outgoingSessionID*: uint8
    incomingSessionID*: uint8
    address*: Address
    data*: pointer
    state*: PeerState
    channels*: ptr Channel
    channelCount*: csize
    incomingBandwidth*: uint32
    outgoingBandwidth*: uint32
    incomingBandwidthThrottleEpoch*: uint32
    outgoingBandwidthThrottleEpoch*: uint32
    incomingDataTotal*: uint32
    outgoingDataTotal*: uint32
    lastSendTime*: uint32
    lastReceiveTime*: uint32
    nextTimeout*: uint32
    earliestTimeout*: uint32
    packetLossEpoch*: uint32
    packetsSent*: uint32
    packetsLost*: uint32
    packetLoss*: uint32
    packetLossVariance*: uint32
    packetThrottle*: uint32
    packetThrottleLimit*: uint32
    packetThrottleCounter*: uint32
    packetThrottleEpoch*: uint32
    packetThrottleAcceleration*: uint32
    packetThrottleDeceleration*: uint32
    packetThrottleInterval*: uint32
    pingInterval*: uint32
    timeoutLimit*: uint32
    timeoutMinimum*: uint32
    timeoutMaximum*: uint32
    lastRoundTripTime*: uint32
    lowestRoundTripTime*: uint32
    lastRoundTripTimeVariance*: uint32
    highestRoundTripTimeVariance*: uint32
    roundTripTime*: uint32
    roundTripTimeVariance*: uint32
    mtu*: uint32
    windowSize*: uint32
    reliableDataInTransit*: uint32
    outgoingReliableSequenceNumber*: uint16
    acknowledgements*: List
    sentReliableCommands*: List
    sentUnreliableCommands*: List
    outgoingReliableCommands*: List
    outgoingUnreliableCommands*: List
    dispatchedCommands*: List
    needsDispatch*: cint
    incomingUnsequencedGroup*: uint16
    outgoingUnsequencedGroup*: uint16
    unsequencedWindow*: array[PEER_UNSEQUENCED_WINDOW_SIZE div 32, uint32]
    eventData*: uint32
    totalWaitingData*: csize

  Compressor* {.bycopy.} = object
    context*: pointer
    compress*: proc (context: pointer; inBuffers: ptr Buffer; inBufferCount: csize; inLimit: csize; outData: ptr uint8; outLimit: csize): csize {.cdecl.}
    decompress*: proc (context: pointer; inData: ptr uint8; inLimit: csize; outData: ptr uint8; outLimit: csize): csize {.cdecl.}
    destroy*: proc (context: pointer) {.cdecl.}

  ChecksumCallback* = proc (buffers: ptr Buffer; bufferCount: csize): uint32 {.cdecl.}

  InterceptCallback* = proc (host: pointer; event: pointer): cint {.cdecl.}  # _Host, _Event

  Host* {.bycopy.} = object
    socket*: Socket
    address*: Address
    incomingBandwidth*: uint32
    outgoingBandwidth*: uint32
    bandwidthThrottleEpoch*: uint32
    mtu*: uint32
    randomSeed*: uint32
    recalculateBandwidthLimits*: cint
    peers*: ptr Peer
    peerCount*: csize
    channelLimit*: csize
    serviceTime*: uint32
    dispatchQueue*: List
    continueSending*: cint
    packetSize*: csize
    headerFlags*: uint16
    commands*: array[PROTOCOL_MAXIMUM_PACKET_COMMANDS, Protocol]
    commandCount*: csize
    buffers*: array[BUFFER_MAXIMUM, Buffer]
    bufferCount*: csize
    checksum*: ChecksumCallback
    compressor*: Compressor
    packetData*: array[2, array[PROTOCOL_MAXIMUM_MTU, uint8]]
    receivedAddress*: Address
    receivedData*: ptr uint8
    receivedDataLength*: csize
    totalSentData*: uint32
    totalSentPackets*: uint32
    totalReceivedData*: uint32
    totalReceivedPackets*: uint32
    intercept*: InterceptCallback
    connectedPeers*: csize
    bandwidthLimitedPeers*: csize
    duplicatePeers*: csize
    maximumPacketSize*: csize
    maximumWaitingData*: csize

  EventType* {.size: sizeof(cint).} = enum
    EVENT_TYPE_NONE = 0, EVENT_TYPE_CONNECT = 1,
    EVENT_TYPE_DISCONNECT = 2, EVENT_TYPE_RECEIVE = 3

  Event* {.bycopy.} = object
    `type`*: EventType
    peer*: ptr Peer
    channelID*: uint8
    data*: uint32
    packet*: ptr Packet

{.push cdecl, dynlib:lib, importc:"enet_$1".}
proc initialize*(): cint
proc initialize_with_callbacks*(version: Version; inits: ptr Callbacks): cint
proc deinitialize*()
proc linked_version*(): Version
proc time_get*(): uint32
proc time_set*(a2: uint32)
proc socket_create*(socketType: SocketType): Socket
proc socket_bind*(socket: Socket; address: ptr Address): cint
proc socket_get_address*(socket: Socket; address: ptr Address): cint  
proc socket_listen*(socket: Socket; a3: cint): cint  
proc socket_accept*(socket: Socket; address: ptr Address): Socket  
proc socket_connect*(socket: Socket; address: ptr Address): cint
proc socket_send*(socket: Socket; address: ptr Address; buffer: ptr Buffer; a5: csize): cint  
proc socket_receive*(socket: Socket; address: ptr Address; buffer: ptr Buffer; a5: csize): cint  
proc socket_wait*(socket: Socket; a3: ptr uint32; a4: uint32): cint  
proc socket_set_option*(socket: Socket; socketOption: SocketOption; a4: cint): cint  
proc socket_get_option*(socket: Socket; socketOption: SocketOption; a4: ptr cint): cint  
proc socket_shutdown*(socket: Socket; socketShutdown: SocketShutdown): cint  
proc socket_destroy*(socket: Socket)  
proc socketset_select*(socket: Socket; socketSet1: ptr SocketSet; socketSet2: ptr SocketSet; a5: uint32): cint  
proc address_set_host*(address: ptr Address; hostName: cstring): cint  
proc address_get_host_ip*(address: ptr Address; hostName: cstring; nameLength: csize): cint  
proc address_get_host*(address: ptr Address; hostName: cstring; nameLength: csize): cint  
proc packet_create*(data: pointer; length: csize; packetFlag: PacketFlag): ptr Packet
proc packet_destroy*(packet: ptr Packet)
proc packet_resize*(packet: ptr Packet; size: csize): cint
proc crc32*(buffer: ptr Buffer; a3: csize): uint32
proc host_create*(address: ptr Address; numConnections: csize; numChannels: csize; inBandwidth: uint32; outBandwidth: uint32): ptr Host
proc host_destroy*(host: ptr Host)
proc host_connect*(host: ptr Host; address: ptr Address; numChannels: csize; data: uint32): ptr Peer  
proc host_check_events*(host: ptr Host; event: ptr Event): cint
proc host_service*(host: ptr Host; event: ptr Event; timeout: uint32): cint  
proc host_flush*(host: ptr Host)
proc host_broadcast*(host: ptr Host; channelId: uint8; packet: ptr Packet)
proc host_compress*(host: ptr Host; compressor: ptr Compressor)
proc host_compress_with_range_coder*(host: ptr Host): cint
proc host_channel_limit*(host: ptr Host; numChannels: csize)
proc host_bandwidth_limit*(host: ptr Host; a3: uint32; a4: uint32)  
proc host_bandwidth_throttle*(host: ptr Host)
proc host_random_seed*(): uint32
proc peer_send*(peer: ptr Peer; channelId: uint8; packet: ptr Packet): cint
proc peer_receive*(peer: ptr Peer; channelID: ptr uint8): ptr Packet  
proc peer_ping*(peer: ptr Peer)  
proc peer_ping_interval*(peer: ptr Peer; a3: uint32)
proc peer_timeout*(peer: ptr Peer; a3: uint32; a4: uint32; a5: uint32)
proc peer_reset*(peer: ptr Peer)
proc peer_disconnect*(peer: ptr Peer; data: uint32)
proc peer_disconnect_now*(peer: ptr Peer; data: uint32)
proc peer_disconnect_later*(peer: ptr Peer; data: uint32)
proc peer_throttle_configure*(peer: ptr Peer; a3: uint32; a4: uint32; a5: uint32)
proc peer_throttle*(peer: ptr Peer; a3: uint32): cint
proc peer_reset_queues*(peer: ptr Peer)
proc peer_setup_outgoing_command*(peer: ptr Peer; a3: ptr OutgoingCommand)  
proc peer_queue_outgoing_command*(peer: ptr Peer; protocol: ptr Protocol; a4: ptr Packet; a5: uint32; a6: uint16): ptr OutgoingCommand  
proc peer_queue_incoming_command*(peer: ptr Peer; protocol: ptr Protocol; a4: pointer; a5: csize; a6: uint32; a7: uint32): ptr IncomingCommand  
proc peer_queue_acknowledgement*(peer: ptr Peer; protocol: ptr Protocol; a4: uint16): ptr Acknowledgement
proc peer_dispatch_incoming_unreliable_commands*(peer: ptr Peer; channel: ptr Channel)
proc peer_dispatch_incoming_reliable_commands*(peer: ptr Peer; channel: ptr Channel)
proc peer_on_connect*(peer: ptr Peer)
proc peer_on_disconnect*(peer: ptr Peer)
proc range_coder_create*(): pointer
proc range_coder_destroy*(a2: pointer)
proc range_coder_compress*(a2: pointer; a3: ptr Buffer; a4: csize; a5: csize; a6: ptr uint8; a7: csize): csize
proc range_coder_decompress*(a2: pointer; a3: ptr uint8; a4: csize; a5: ptr uint8; a6: csize): csize
proc protocol_command_size*(a2: uint8): csize

# list
proc list_clear*(list: ptr List)  
proc list_insert*(listIterator: ListIterator; a3: pointer): ListIterator  
proc list_remove*(listIterator: ListIterator): pointer  
proc list_move*(listIterator: ListIterator; a3: pointer; a4: pointer): ListIterator
proc list_size*(list: ptr List): csize  

proc malloc*(size: csize): pointer  
proc free*(data: pointer)  
{.pop.}
