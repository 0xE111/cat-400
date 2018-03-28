import tables
from streams import Stream

import msgpack4nim
export msgpack4nim


type
  PackProc*[T] = proc(s: Stream, value: ref T) {.closure.}
  UnpackProc*[T] = proc(s: Stream, value: var ref T) {.closure.}
  PackTable*[T] = Table[int8, tuple[pack: PackProc[T], unpack: UnpackProc[T]]]

proc getPackTable*(T: typedesc): ref PackTable[T] =
  var table {.global.} = newTable[int8, tuple[pack: PackProc[T], unpack: UnpackProc[T]]]()
  return table

template register*(T: typedesc): untyped =
  method packId(value: ref T): int8 {.base.} = (-1).int8

  proc pack_type*(s: Stream, value: ref T) =
    var
      packId = value.packId
      packTable = getPackTable(T)

    s.pack packId
    if packTable.hasKey(packId):
      packTable[packId].pack(s, value)
    else:
      s.pack value[]
  
  proc unpack_type*(s: Stream, value: var ref T) =
    var
      packId: int8
      packTable = getPackTable(T)

    s.unpack packId
    if packTable.hasKey(packId):
      packTable[packId].unpack(s, value)
    else:
      new(value)
      s.unpack value[]

template register*(T: typedesc, C: typedesc): untyped =
  var packTable = getPackTable(T)
  let id = packTable.len.int8

  method packId(value: ref C): int8 = id

  packTable.add(
    id,
    (
      proc(s: Stream, value: ref T) {.closure.} =
        s.pack((ref C)(value)),
      proc(s: Stream, value: var ref T) {.closure.} =
        var t: ref C
        s.unpack(t)
        value = t,
        # s.unpack((ref C)(value)),  # TODO: use this
    )
  )


when isMainModule:
  type
    Base = object {.inheritable.}
    ChildA = object of Base
      msg: string
    ChildB = object of Base
      counter: int8

  method getData(x: ref Base): string {.base.} = ""
  method getData(x: ref ChildA): string = x.msg
  method getData(x: ref ChildB): string = $x.counter

  # SETUP
  register(Base)
  register(Base, ChildA)
  register(Base, ChildB)

  # PACK TEST
  var
    base: ref Base
    childA: ref ChildA
    childB: ref ChildB

  var
    packed: string
    unpacked: ref Base

  new(base)
  new(childA)
  childA.msg = "some message"
  new(childB)
  childB.counter = 42
  echo "----------------------------"

  echo "Checking Base..."
  packed = pack(base)
  echo "Packed: " & stringify(packed)
  packed.unpack(unpacked)
  assert(unpacked.getData() == "")
  echo "----------------------------"
 
  echo "Checking ChildA..."
  base = childA
  packed = pack(base)
  echo "Packed: " & stringify(packed)
  packed.unpack(unpacked)
  assert(unpacked.getData() == "some message")
  echo "----------------------------"
  
  echo "Checking ChildB..."
  base = childB
  packed = pack(base)
  echo "Packed: " & stringify(packed)
  packed.unpack(unpacked)
  assert(unpacked.getData() == "42")
  echo "----------------------------"

  echo "Checks passed!"
