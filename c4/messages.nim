## Message is a base unit for communication between systems.

import hashes
import tables
export tables
import macros
import locks
import typetraits
import msgpack4nim
export msgpack4nim  # every module using messages packing must import msgpack4nim


type
  Message* {.inheritable.} = object
    ## Message is an object with minimal required information to describe some event or command.
    ## Call `messages.register` on message subtype so that msgpack4nim knows how to (de)serialize it.
    ## Example:
    ##   type CustomMessage = object of Message
    ##   messages.register(CustomMessage)

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
method `$`*(self: ref Message): string {.base.} = "Message"

method packId*(self: ref Message): uint8 {.base.} =
  raise newException(LibraryError, "Trying to pack/unpack base Message type, probably forgot to call `register()` on custom message type")

proc msgpack*(message: ref Message): string {.gcsafe.} =
  ## General method which selects appropriate pack method from pack table according to real message runtime type.
  # var packProc: PackProc
  # withLock packTableLock:
  #   packProc = packTablePtr[][message.packId].pack
  # result = packProc(message)

  {.gcsafe.}:  # im so sorry for this
    withLock packTableLock:
      try:
        result = packTablePtr[][message.packId].pack(message)
      except KeyError:
        raise newException(LibraryError, "Unknown message type id: " & $message.packId)

proc msgunpack*(data: string): ref Message {.gcsafe.} =
  ## General method which selects appropriate unpack method from pack table according to real message runtime type.
  var
    packId: uint8
    stream = MsgStream.init(data)

  # stream.setPosition(0)  # TODO: why was it needed?
  stream.unpack(packId)
  {.gcsafe.}:
    withLock packTableLock:
      try:
        result = packTablePtr[][packId].unpack(stream)
      except KeyError:
        raise newException(LibraryError, "Unknown message type id: " & $packId)

template register*(MessageType: typedesc) =
  ## Template for registering pack/unpack procs for specific message type.
  ## Without registering, packing/unpacking won't store runtime type information.
  var messageId: uint8

  withLock packTableLock:
    messageId = uint8(packTable.len) + 1

    packTablePtr[][messageId] = (
      # pack proc
      proc(message: ref Message): string {.closure.} =
        let packId = messageId
        # var stream = MsgStream.init(sizeof(packId) + sizeof(MessageType))
        var stream = MsgStream.init()

        stream.pack packId
        stream.pack (ref MessageType) message

        result = stream.data,

      # unpack proc
      proc(stream: MsgStream): ref Message {.closure.} =
        var temp: ref MessageType
        stream.unpack(temp)
        result = temp
    )

  method packId*(self: ref MessageType): uint8 = messageId

  method `$`*(self: ref MessageType): string =
    result = self[].type.name
    for name, value in self[].fieldPairs:
      result.add(" " & name & "=[" & $value & "]")

  proc msgpack*(self: ref MessageType): string = ((ref Message)self).msgpack()  # required for instant pack


when isMainModule:
  import unittest

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
      packed: string
      unpacked: ref Message

    test "Pack/unpack base Message type":
      expect LibraryError:
        packed = new(Message).msgpack()

    test "Pack/unpack Message subtypes":
      var message: ref Message

      message = (ref MessageA)(msg: "some message")
      packed = message.msgpack()
      echo "MessageA packed as: " & stringify(packed)
      unpacked = packed.msgunpack()

      check:
        packed.len == 15
        unpacked.getData() == "some message"

      message = (ref MessageB)(counter: 42, data: "some data string", is_correct: true)
      packed = message.msgpack()
      echo "MessageB packed as: " & stringify(packed)
      unpacked = packed.msgunpack()
      check:
        packed.len == 21
        unpacked.getData() == "42"

    test "Instant pack":
      let packedInstant = (ref MessageB)(counter: 42).msgpack()
      echo "Instant packed as: " & stringify(packedInstant)

      var msg: ref Message = (ref MessageB)(counter: 42)
      let packedVariable = msg.msgpack()
      echo "Var packed as: " & stringify(packedVariable)

      check:
        packedInstant == packedVariable

    test "Inside a thread":
      var thread: Thread[void]

      thread.createThread(tp = proc() {.thread.} =
        let packed = (ref MessageB)(counter: 42).msgpack()
        discard packed.msgunpack()
      )
