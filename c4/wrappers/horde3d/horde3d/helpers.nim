import "../horde3d"
import vecutils


type
  NodeTransform* = tuple[tx, ty, tz, rx, ry, rz, sx, sy, sz: cfloat]


proc getTransform*(node: horde3d.Node): NodeTransform =
  ## High-level wrapper for getting Horde3d.Node transform values.
  node.getNodeTransform(
    result.tx.addr, result.ty.addr, result.tz.addr,
    result.rx.addr, result.ry.addr, result.rz.addr,
    result.sx.addr, result.sy.addr, result.sz.addr,
  )

proc relTranslate(node: Node, vector: Vector) =
  ## Translates node relative to its direction
  let
    curTransform = node.getTransform()
    vector = vector.rotate(curTransform.rx, curTransform.ry)

  node.setNodeTransform(
    curTransform.tx + vector[0], curTransform.ty + vector[1], curTransform.tz + vector[2],
    curTransform.rx, curTransform.ry, curTransform.rz,
    curTransform.sx, curTransform.sy, curTransform.sz,
  )
