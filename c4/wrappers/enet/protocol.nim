import
  types

const
  ENET_PROTOCOL_MINIMUM_MTU* = 576
  ENET_PROTOCOL_MAXIMUM_MTU* = 4096
  ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS* = 32
  ENET_PROTOCOL_MINIMUM_WINDOW_SIZE* = 4096
  ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE* = 65536
  ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT* = 1
  ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT* = 255
  ENET_PROTOCOL_MAXIMUM_PEER_ID* = 0x00000FFF
  ENET_PROTOCOL_MAXIMUM_FRAGMENT_COUNT* = 1024 * 1024

type
  ENetProtocolCommand* = enum
    ENET_PROTOCOL_COMMAND_NONE = 0, ENET_PROTOCOL_COMMAND_ACKNOWLEDGE = 1,
    ENET_PROTOCOL_COMMAND_CONNECT = 2, ENET_PROTOCOL_COMMAND_VERIFY_CONNECT = 3,
    ENET_PROTOCOL_COMMAND_DISCONNECT = 4, ENET_PROTOCOL_COMMAND_PING = 5,
    ENET_PROTOCOL_COMMAND_SEND_RELIABLE = 6,
    ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE = 7,
    ENET_PROTOCOL_COMMAND_SEND_FRAGMENT = 8,
    ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED = 9,
    ENET_PROTOCOL_COMMAND_BANDWIDTH_LIMIT = 10,
    ENET_PROTOCOL_COMMAND_THROTTLE_CONFIGURE = 11,
    ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT = 12,
    ENET_PROTOCOL_COMMAND_COUNT = 13, ENET_PROTOCOL_COMMAND_MASK = 0x0000000F
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
