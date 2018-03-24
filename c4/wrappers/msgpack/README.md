# Msgpack

This is an extension for [msgpack4nim](https://github.com/jangko/msgpack4nim).

## About

By default msgpack4nim doesn't support inheritance, which makes you think about how to convert your object to/from string. This extension allows you to serialize and deserialize your base and inhereted objects, preserving runtime types and field values.

## Reference

Based on several articles, for example https://isocpp.org/wiki/faq/serialization#serialize-inherit-no-ptrs.



## Installation

Install directly from git subdir:

```sh
nimble install "https://github.com/c0ntribut0r/cat-400?subdir=c4/wrappers/msgpack@#head"
```

## Usage

Use `register(BaseClass)` and then `register(BaseClass, ChildClass)`.
Now when you call `pack` on `ref BaseClass`:
- Internal runtime type's id will be packed. BaseClass instance will have id == -1, ChildClass instance will have id == 0 etc.
- The class will be packed with respect to its runtime type (remember, you call `pack(ref BaseClass)` but this extension enforces packing of correct runtime type, as if you called `pack((ref ChildClass)(ref BaseClass))`).

`Unpack` will do the same - when you `unpack(ref BaseClass)`, it will still preserve correct runtime type and data.

```nim
import msgpack

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
