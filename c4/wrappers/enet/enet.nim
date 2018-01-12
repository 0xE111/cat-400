 {.deadCodeElim: on.}
when defined(windows):
  const
    lib* = "enet.dll"
elif defined(macosx):
  const
    lib* = "enet.dylib"
else:
  const
    lib* = "libenet.so"
when defined(windows):
  import
    ./win32

else:
  import
    ./unix

import
  types, protocol, list, callbacks

const
  ENET_VERSION_MAJOR* = 1
  ENET_VERSION_MINOR* = 3
  ENET_VERSION_PATCH* = 13

template ENET_VERSION_CREATE*(major, minor, patch: untyped): untyped =
  (((major) shl 16) or ((minor) shl 8) or (patch))

template ENET_VERSION_GET_MAJOR*(version: untyped): untyped =
  (((version) shr 16) and 0x000000FF)

template ENET_VERSION_GET_MINOR*(version: untyped): untyped =
  (((version) shr 8) and 0x000000FF)

template ENET_VERSION_GET_PATCH*(version: untyped): untyped =
  ((version) and 0x000000FF)

const
  ENET_VERSION* = ENET_VERSION_CREATE(ENET_VERSION_MAJOR, ENET_VERSION_MINOR,
                                    ENET_VERSION_PATCH)

type
  ENetVersion* = enet_uint32
  _ENetHost* {.bycopy.} = object
  
  _ENetEvent* {.bycopy.} = object
  
  _ENetPacket* {.bycopy.} = object
  
  ENetSocketType* {.size: sizeof(cint).} = enum
    ENET_SOCKET_TYPE_STREAM = 1, ENET_SOCKET_TYPE_DATAGRAM = 2
  ENetSocketWait* {.size: sizeof(cint).} = enum
    ENET_SOCKET_WAIT_NONE = 0, ENET_SOCKET_WAIT_SEND = (1 shl 0),
    ENET_SOCKET_WAIT_RECEIVE = (1 shl 1), ENET_SOCKET_WAIT_INTERRUPT = (1 shl 2)
  ENetSocketOption* {.size: sizeof(cint).} = enum
    ENET_SOCKOPT_NONBLOCK = 1, ENET_SOCKOPT_BROADCAST = 2, ENET_SOCKOPT_RCVBUF = 3,
    ENET_SOCKOPT_SNDBUF = 4, ENET_SOCKOPT_REUSEADDR = 5, ENET_SOCKOPT_RCVTIMEO = 6,
    ENET_SOCKOPT_SNDTIMEO = 7, ENET_SOCKOPT_ERROR = 8, ENET_SOCKOPT_NODELAY = 9
  ENetSocketShutdown* {.size: sizeof(cint).} = enum
    ENET_SOCKET_SHUTDOWN_READ = 0, ENET_SOCKET_SHUTDOWN_WRITE = 1,
    ENET_SOCKET_SHUTDOWN_READ_WRITE = 2





const
  ENET_HOST_ANY* = 0
  ENET_HOST_BROADCAST* = 0xFFFFFFFF
  ENET_PORT_ANY* = 0


type
  ENetAddress* {.bycopy.} = object
    host*: enet_uint32
    port*: enet_uint16



type
  ENetPacketFlag* {.size: sizeof(cint).} = enum
    ENET_PACKET_FLAG_RELIABLE = (1 shl 0), ENET_PACKET_FLAG_UNSEQUENCED = (1 shl 1),
    ENET_PACKET_FLAG_NO_ALLOCATE = (1 shl 2),
    ENET_PACKET_FLAG_UNRELIABLE_FRAGMENT = (1 shl 3),
    ENET_PACKET_FLAG_SENT = (1 shl 8)
  ENetPacketFreeCallback* = proc (a2: ptr _ENetPacket) {.cdecl.}



type
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
    ENET_PEER_STATE_DISCONNECTED = 0, ENET_PEER_STATE_CONNECTING = 1,
    ENET_PEER_STATE_ACKNOWLEDGING_CONNECT = 2,
    ENET_PEER_STATE_CONNECTION_PENDING = 3,
    ENET_PEER_STATE_CONNECTION_SUCCEEDED = 4, ENET_PEER_STATE_CONNECTED = 5,
    ENET_PEER_STATE_DISCONNECT_LATER = 6, ENET_PEER_STATE_DISCONNECTING = 7,
    ENET_PEER_STATE_ACKNOWLEDGING_DISCONNECT = 8, ENET_PEER_STATE_ZOMBIE = 9


const
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

type
  ENetChannel* {.bycopy.} = object
    outgoingReliableSequenceNumber*: enet_uint16
    outgoingUnreliableSequenceNumber*: enet_uint16
    usedReliableWindows*: enet_uint16
    reliableWindows*: array[ENET_PEER_RELIABLE_WINDOWS, enet_uint16]
    incomingReliableSequenceNumber*: enet_uint16
    incomingUnreliableSequenceNumber*: enet_uint16
    incomingReliableCommands*: ENetList
    incomingUnreliableCommands*: ENetList



type
  ENetPeer* {.bycopy.} = object
    dispatchList*: ENetListNode
    host*: ptr _ENetHost
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



type
  ENetCompressor* {.bycopy.} = object
    context*: pointer
    compress*: proc (context: pointer; inBuffers: ptr ENetBuffer; inBufferCount: csize;
                   inLimit: csize; outData: ptr enet_uint8; outLimit: csize): csize {.
        cdecl.}
    decompress*: proc (context: pointer; inData: ptr enet_uint8; inLimit: csize;
                     outData: ptr enet_uint8; outLimit: csize): csize {.cdecl.}
    destroy*: proc (context: pointer) {.cdecl.}



type
  ENetChecksumCallback* = proc (buffers: ptr ENetBuffer; bufferCount: csize): enet_uint32 {.
      cdecl.}


type
  ENetInterceptCallback* = proc (host: ptr _ENetHost; event: ptr _ENetEvent): cint {.cdecl.}


type
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



type
  ENetEventType* {.size: sizeof(cint).} = enum
    ENET_EVENT_TYPE_NONE = 0, ENET_EVENT_TYPE_CONNECT = 1,
    ENET_EVENT_TYPE_DISCONNECT = 2, ENET_EVENT_TYPE_RECEIVE = 3



type
  ENetEvent* {.bycopy.} = object
    `type`*: ENetEventType
    peer*: ptr ENetPeer
    channelID*: enet_uint8
    data*: enet_uint32
    packet*: ptr ENetPacket



proc enet_initialize*(): cint {.cdecl, importc: "enet_initialize", dynlib: lib.}

proc enet_initialize_with_callbacks*(version: ENetVersion; inits: ptr ENetCallbacks): cint {.
    cdecl, importc: "enet_initialize_with_callbacks", dynlib: lib.}

proc enet_deinitialize*() {.cdecl, importc: "enet_deinitialize", dynlib: lib.}

proc enet_linked_version*(): ENetVersion {.cdecl, importc: "enet_linked_version",
                                        dynlib: lib.}

proc enet_time_get*(): enet_uint32 {.cdecl, importc: "enet_time_get", dynlib: lib.}

proc enet_time_set*(a2: enet_uint32) {.cdecl, importc: "enet_time_set", dynlib: lib.}

proc enet_socket_create*(a2: ENetSocketType): ENetSocket {.cdecl,
    importc: "enet_socket_create", dynlib: lib.}
proc enet_socket_bind*(a2: ENetSocket; a3: ptr ENetAddress): cint {.cdecl,
    importc: "enet_socket_bind", dynlib: lib.}
proc enet_socket_get_address*(a2: ENetSocket; a3: ptr ENetAddress): cint {.cdecl,
    importc: "enet_socket_get_address", dynlib: lib.}
proc enet_socket_listen*(a2: ENetSocket; a3: cint): cint {.cdecl,
    importc: "enet_socket_listen", dynlib: lib.}
proc enet_socket_accept*(a2: ENetSocket; a3: ptr ENetAddress): ENetSocket {.cdecl,
    importc: "enet_socket_accept", dynlib: lib.}
proc enet_socket_connect*(a2: ENetSocket; a3: ptr ENetAddress): cint {.cdecl,
    importc: "enet_socket_connect", dynlib: lib.}
proc enet_socket_send*(a2: ENetSocket; a3: ptr ENetAddress; a4: ptr ENetBuffer; a5: csize): cint {.
    cdecl, importc: "enet_socket_send", dynlib: lib.}
proc enet_socket_receive*(a2: ENetSocket; a3: ptr ENetAddress; a4: ptr ENetBuffer;
                         a5: csize): cint {.cdecl, importc: "enet_socket_receive",
    dynlib: lib.}
proc enet_socket_wait*(a2: ENetSocket; a3: ptr enet_uint32; a4: enet_uint32): cint {.
    cdecl, importc: "enet_socket_wait", dynlib: lib.}
proc enet_socket_set_option*(a2: ENetSocket; a3: ENetSocketOption; a4: cint): cint {.
    cdecl, importc: "enet_socket_set_option", dynlib: lib.}
proc enet_socket_get_option*(a2: ENetSocket; a3: ENetSocketOption; a4: ptr cint): cint {.
    cdecl, importc: "enet_socket_get_option", dynlib: lib.}
proc enet_socket_shutdown*(a2: ENetSocket; a3: ENetSocketShutdown): cint {.cdecl,
    importc: "enet_socket_shutdown", dynlib: lib.}
proc enet_socket_destroy*(a2: ENetSocket) {.cdecl, importc: "enet_socket_destroy",
    dynlib: lib.}
proc enet_socketset_select*(a2: ENetSocket; a3: ptr ENetSocketSet;
                           a4: ptr ENetSocketSet; a5: enet_uint32): cint {.cdecl,
    importc: "enet_socketset_select", dynlib: lib.}

proc enet_address_set_host*(address: ptr ENetAddress; hostName: cstring): cint {.cdecl,
    importc: "enet_address_set_host", dynlib: lib.}

proc enet_address_get_host_ip*(address: ptr ENetAddress; hostName: cstring;
                              nameLength: csize): cint {.cdecl,
    importc: "enet_address_get_host_ip", dynlib: lib.}

proc enet_address_get_host*(address: ptr ENetAddress; hostName: cstring;
                           nameLength: csize): cint {.cdecl,
    importc: "enet_address_get_host", dynlib: lib.}

proc enet_packet_create*(a2: pointer; a3: csize; a4: enet_uint32): ptr ENetPacket {.
    cdecl, importc: "enet_packet_create", dynlib: lib.}
proc enet_packet_destroy*(a2: ptr ENetPacket) {.cdecl,
    importc: "enet_packet_destroy", dynlib: lib.}
proc enet_packet_resize*(a2: ptr ENetPacket; a3: csize): cint {.cdecl,
    importc: "enet_packet_resize", dynlib: lib.}
proc enet_crc32*(a2: ptr ENetBuffer; a3: csize): enet_uint32 {.cdecl,
    importc: "enet_crc32", dynlib: lib.}
proc enet_host_create*(a2: ptr ENetAddress; a3: csize; a4: csize; a5: enet_uint32;
                      a6: enet_uint32): ptr ENetHost {.cdecl,
    importc: "enet_host_create", dynlib: lib.}
proc enet_host_destroy*(a2: ptr ENetHost) {.cdecl, importc: "enet_host_destroy",
                                        dynlib: lib.}
proc enet_host_connect*(a2: ptr ENetHost; a3: ptr ENetAddress; a4: csize; a5: enet_uint32): ptr ENetPeer {.
    cdecl, importc: "enet_host_connect", dynlib: lib.}
proc enet_host_check_events*(a2: ptr ENetHost; a3: ptr ENetEvent): cint {.cdecl,
    importc: "enet_host_check_events", dynlib: lib.}
proc enet_host_service*(a2: ptr ENetHost; a3: ptr ENetEvent; a4: enet_uint32): cint {.
    cdecl, importc: "enet_host_service", dynlib: lib.}
proc enet_host_flush*(a2: ptr ENetHost) {.cdecl, importc: "enet_host_flush",
                                      dynlib: lib.}
proc enet_host_broadcast*(a2: ptr ENetHost; a3: enet_uint8; a4: ptr ENetPacket) {.cdecl,
    importc: "enet_host_broadcast", dynlib: lib.}
proc enet_host_compress*(a2: ptr ENetHost; a3: ptr ENetCompressor) {.cdecl,
    importc: "enet_host_compress", dynlib: lib.}
proc enet_host_compress_with_range_coder*(host: ptr ENetHost): cint {.cdecl,
    importc: "enet_host_compress_with_range_coder", dynlib: lib.}
proc enet_host_channel_limit*(a2: ptr ENetHost; a3: csize) {.cdecl,
    importc: "enet_host_channel_limit", dynlib: lib.}
proc enet_host_bandwidth_limit*(a2: ptr ENetHost; a3: enet_uint32; a4: enet_uint32) {.
    cdecl, importc: "enet_host_bandwidth_limit", dynlib: lib.}
proc enet_host_bandwidth_throttle*(a2: ptr ENetHost) {.cdecl,
    importc: "enet_host_bandwidth_throttle", dynlib: lib.}
proc enet_host_random_seed*(): enet_uint32 {.cdecl,
    importc: "enet_host_random_seed", dynlib: lib.}
proc enet_peer_send*(a2: ptr ENetPeer; a3: enet_uint8; a4: ptr ENetPacket): cint {.cdecl,
    importc: "enet_peer_send", dynlib: lib.}
proc enet_peer_receive*(a2: ptr ENetPeer; channelID: ptr enet_uint8): ptr ENetPacket {.
    cdecl, importc: "enet_peer_receive", dynlib: lib.}
proc enet_peer_ping*(a2: ptr ENetPeer) {.cdecl, importc: "enet_peer_ping", dynlib: lib.}
proc enet_peer_ping_interval*(a2: ptr ENetPeer; a3: enet_uint32) {.cdecl,
    importc: "enet_peer_ping_interval", dynlib: lib.}
proc enet_peer_timeout*(a2: ptr ENetPeer; a3: enet_uint32; a4: enet_uint32;
                       a5: enet_uint32) {.cdecl, importc: "enet_peer_timeout",
                                        dynlib: lib.}
proc enet_peer_reset*(a2: ptr ENetPeer) {.cdecl, importc: "enet_peer_reset",
                                      dynlib: lib.}
proc enet_peer_disconnect*(a2: ptr ENetPeer; a3: enet_uint32) {.cdecl,
    importc: "enet_peer_disconnect", dynlib: lib.}
proc enet_peer_disconnect_now*(a2: ptr ENetPeer; a3: enet_uint32) {.cdecl,
    importc: "enet_peer_disconnect_now", dynlib: lib.}
proc enet_peer_disconnect_later*(a2: ptr ENetPeer; a3: enet_uint32) {.cdecl,
    importc: "enet_peer_disconnect_later", dynlib: lib.}
proc enet_peer_throttle_configure*(a2: ptr ENetPeer; a3: enet_uint32; a4: enet_uint32;
                                  a5: enet_uint32) {.cdecl,
    importc: "enet_peer_throttle_configure", dynlib: lib.}
proc enet_peer_throttle*(a2: ptr ENetPeer; a3: enet_uint32): cint {.cdecl,
    importc: "enet_peer_throttle", dynlib: lib.}
proc enet_peer_reset_queues*(a2: ptr ENetPeer) {.cdecl,
    importc: "enet_peer_reset_queues", dynlib: lib.}
proc enet_peer_setup_outgoing_command*(a2: ptr ENetPeer; a3: ptr ENetOutgoingCommand) {.
    cdecl, importc: "enet_peer_setup_outgoing_command", dynlib: lib.}
proc enet_peer_queue_outgoing_command*(a2: ptr ENetPeer; a3: ptr ENetProtocol;
                                      a4: ptr ENetPacket; a5: enet_uint32;
                                      a6: enet_uint16): ptr ENetOutgoingCommand {.
    cdecl, importc: "enet_peer_queue_outgoing_command", dynlib: lib.}
proc enet_peer_queue_incoming_command*(a2: ptr ENetPeer; a3: ptr ENetProtocol;
                                      a4: pointer; a5: csize; a6: enet_uint32;
                                      a7: enet_uint32): ptr ENetIncomingCommand {.
    cdecl, importc: "enet_peer_queue_incoming_command", dynlib: lib.}
proc enet_peer_queue_acknowledgement*(a2: ptr ENetPeer; a3: ptr ENetProtocol;
                                     a4: enet_uint16): ptr ENetAcknowledgement {.
    cdecl, importc: "enet_peer_queue_acknowledgement", dynlib: lib.}
proc enet_peer_dispatch_incoming_unreliable_commands*(a2: ptr ENetPeer;
    a3: ptr ENetChannel) {.cdecl, importc: "enet_peer_dispatch_incoming_unreliable_commands",
                        dynlib: lib.}
proc enet_peer_dispatch_incoming_reliable_commands*(a2: ptr ENetPeer;
    a3: ptr ENetChannel) {.cdecl, importc: "enet_peer_dispatch_incoming_reliable_commands",
                        dynlib: lib.}
proc enet_peer_on_connect*(a2: ptr ENetPeer) {.cdecl,
    importc: "enet_peer_on_connect", dynlib: lib.}
proc enet_peer_on_disconnect*(a2: ptr ENetPeer) {.cdecl,
    importc: "enet_peer_on_disconnect", dynlib: lib.}
proc enet_range_coder_create*(): pointer {.cdecl,
                                        importc: "enet_range_coder_create",
                                        dynlib: lib.}
proc enet_range_coder_destroy*(a2: pointer) {.cdecl,
    importc: "enet_range_coder_destroy", dynlib: lib.}
proc enet_range_coder_compress*(a2: pointer; a3: ptr ENetBuffer; a4: csize; a5: csize;
                               a6: ptr enet_uint8; a7: csize): csize {.cdecl,
    importc: "enet_range_coder_compress", dynlib: lib.}
proc enet_range_coder_decompress*(a2: pointer; a3: ptr enet_uint8; a4: csize;
                                 a5: ptr enet_uint8; a6: csize): csize {.cdecl,
    importc: "enet_range_coder_decompress", dynlib: lib.}
proc enet_protocol_command_size*(a2: enet_uint8): csize {.cdecl,
    importc: "enet_protocol_command_size", dynlib: lib.}