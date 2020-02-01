import unittest
import macros


template `as`*(obj: typed, T: typedesc): untyped =
  T(obj)


macro operateOn*(x: typed; calls: untyped) =
  # TODO: remove when `operateOn` is merged to master
  result = copyNimNode(calls)
  expectKind calls, {nnkStmtList, nnkStmtListExpr}
  # non-recursive processing because that's exactly what we need here:
  for y in calls:
    expectKind y, nnkCallKinds
    var call = newTree(y.kind)
    call.add y[0]
    call.add x
    for j in 1..<y.len: call.add y[j]
    result.add call


when isMainModule:
  type
    A {.inheritable.} = object
    B = object of A

  suite "types":
    test "as":
      let b = new(B)
      let a = b.as(ref A)
      let a1 = b as ref A
