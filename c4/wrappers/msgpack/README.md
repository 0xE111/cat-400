# Msgpack

This is an extension for [msgpack4nim](https://github.com/jangko/msgpack4nim).

## About

By default msgpack4nim doesn't support inheritance, which makes you think about how to convert your object to/from string. This extension allows you to serialize and deserialize your base and inhereted objects, preserving runtime types and field values.

## Installation

Install directly from git subdir:

```sh
nimble install "https://github.com/c0ntribut0r/cat-400?subdir=c4/wrappers/msgpack@#head"
```
## Usage

```nim
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
```

## License

MIT. Do whatever you want.
