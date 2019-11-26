## Message is a base unit for communication between systems.

import hashes
import tables
export tables
import macros
import locks
import typetraits
import msgpack4nim
export msgpack4nim  # every module using messages packing must import msgpack4nim

when isMainModule:
  import unittest


type
  Peer* {.inheritable.} = object
    ## This is a type for addressing an entity in network connection. ``Peer`` may refer to a server or one of its clients.
    discard

  Message* {.inheritable.} = object
    ## Message is an object with minimal required information to describe some event or command.
    ## Every message contains a reference to a sender (Peer).
    ## Network system should populate the `peer` field when receiving Message from remote machine.
    ## You need to call `core.messages.register` so that msgpack4nim knows how to (de)serialize your custom message.
    sender*: ref Peer  ## Message sender; nil means that the message is local.
    recipient*: ref Peer  ## Message recipient; nil means that the message should be broadcasted.


method `$`*(self: Peer): string {.base.} =
  ## Just ``Peer``'s address. It should definitely be redefined in network module.
  # TODO: Redefine in network module
  result = $cast[int](self.unsafeAddr)

proc isLocal*(self: ref Message): bool =
  ## Check whether this message is local or from external Peer
  self.sender.isNil

proc hash*(self: ref Peer): Hash =
  result = self[].addr.hash
  # result = !$result

method isReliable*(self: ref Message): bool {.base, inline.} =
  ## Whether this message should be sent reliably over the network.
  ## - Unreliable messages may be lost, delivery is not guaranteed;
  ## - Reliable messages may product overhead to network communication.
  false


# ---- msgpack stuff ----
type
  PackProc = proc(message: ref Message): string {.closure.}
  UnpackProc = proc(stream: MsgStream): ref Message {.closure.}

var packTable = initTable[
  uint8,
  tuple[
    pack: PackProc,
    unpack: UnpackProc,
  ],
]()
let packTablePtr = packTable.addr
var packTableLock: Lock
initLock(packTableLock)

# -- Message --
method packId*(self: ref Message): uint8 {.base.} =
  raise newException(LibraryError, "Trying to pack/unpack base Message type")
method `$`*(self: ref Message): string {.base.} = "Message"

proc pack*(message: ref Message): string =
  ## General method which selects appropriate pack method from pack table according to real message runtime type.
  withLock packTableLock:
    result = packTablePtr[][message.packId].pack(message)

proc unpack*(data: string): ref Message =
  ## General method which selects appropriate unpack method from pack table according to real message runtime type.
  var
    packId: uint8
    stream = MsgStream.init(data)

  stream.setPosition(0)
  stream.unpack(packId)
  withLock packTableLock:
    result = packTablePtr[][packId].unpack(stream)

# -- Message subtype --
template register*(MessageType: typedesc) =
  var messageId: uint8

  withLock packTableLock:
    messageId = uint8(packTable.len) + 1

    packTablePtr[][messageId] = (
      # pack proc
      proc(message: ref Message): string {.closure.} =
        let packId = messageId
        var stream = MsgStream.init(sizeof(packId) + sizeof(MessageType))

        stream.pack packId
        stream.pack (ref MessageType)message

        result = stream.data,

      proc(stream: MsgStream): ref Message {.closure.} =
        var temp: ref MessageType
        stream.unpack(temp)
        result = temp
    )

  method packId*(self: ref MessageType): uint8 = messageId
  method `$`*(self: ref MessageType): string = $(self[].type) & $self[]


when isMainModule:
  type
    MessageA = object of Message
      msg: string
    MessageB = object of Message
      counter: int8
      data: string
      is_correct: bool

  method getData(x: ref Message): string {.base.} = ""
  method getData(x: ref MessageA): string = x.msg
  method getData(x: ref MessageB): string = $x.counter

  register(MessageA)
  register(MessageB)

  suite "Messages test":
    var
      message: ref Message
      messageA: ref MessageA
      messageB: ref MessageB

    var
      packed: string
      unpacked: ref Message

    new(message)
    new(messageA)
    messageA.msg = "some message"
    messageA.sender = new(ref Peer)
    new(messageB)
    messageB.counter = 42
    messageB.data = "some data string"
    messageB.is_correct = true

    test "Pack/unpack base Message type":
      expect LibraryError:
        packed = pack(message)

    test "Pack/unpack Message subtypes":
      message = messageA
      packed = pack(message)
      # echo "MessageA packed as: " & stringify(packed)
      unpacked = packed.unpack()
      check:
        packed.len == 17
        unpacked.getData() == "some message"

      message = messageB
      packed = pack(message)
      # echo "MessageB packed as: " & stringify(packed)
      unpacked = packed.unpack()
      check:
        packed.len == 23
        unpacked.getData() == "42"
