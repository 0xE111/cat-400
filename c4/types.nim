import unittest


template `as`*(obj: typed, T: typedesc): untyped =
  T(obj)


when isMainModule:
  type
    A {.inheritable.} = object
    B = object of A

  suite "types":
    test "as":
      let b = new(B)
      let a = b.as(ref A)
      let a1 = b as ref A
