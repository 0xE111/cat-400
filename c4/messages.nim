## Message is a base unit for communication between systems.

import hashes
import sharedtables
export sharedtables
import macros
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

var packTable: SharedTable[
  uint8,
  tuple[
    pack: PackProc,
    unpack: UnpackProc,
  ],
]
packTable.init(64)
var lastId = 0.uint8


# -- Message --
method packId*(self: ref Message): uint8 {.base.} =
  raise newException(LibraryError, "Trying to pack/unpack base Message type")
method `$`*(self: ref Message): string {.base.} = "Message"

proc pack*(message: ref Message): string =
  ## General method which selects appropriate pack method from pack table according to real message runtime type.
  packTable.withValue(key=message.packId, value) do:
    result = value.pack(message)

proc unpack*(data: string): ref Message =
  ## General method which selects appropriate unpack method from pack table according to real message runtime type.
  var
    packId: uint8
    stream = MsgStream.init(data)

  stream.setPosition(0)
  stream.unpack(packId)
  packTable.withValue(key=packId, value) do:
    result = value.unpack(stream)

# -- Message subtype --
template register*(MessageType: typedesc) =
  # let messageId = uint8(packTable.len + 1)
  let messageId = lastId
  lastId += 1

  method packId*(self: ref MessageType): uint8 = messageId.uint8
  method `$`*(self: ref MessageType): string = $(self[].type) & $self[]

  packTable.withKey(messageId) do (key: uint8, value: var tuple[pack: PackProc, unpack: UnpackProc], pairExists: var bool):
    if pairExists:
      raise newException(LibraryError, "ID of message " & $MessageType.name & " ({messageId}) was already registered in packTable")

    value.pack = proc(message: ref Message): string {.closure.} =
      let packId = messageId
      var stream = MsgStream.init(sizeof(packId) + sizeof(MessageType))

      stream.pack packId
      stream.pack (ref MessageType)message

      result = stream.data

    value.unpack = proc(stream: MsgStream): ref Message {.closure.} =
      var temp: ref MessageType
      stream.unpack(temp)
      result = temp

    pairExists = true


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
