import math


type
  Vector* = seq[float]
  Matrix* = seq[seq[float]]

proc `*`*(M: Matrix, v: Vector): Vector =
  result = @[]
  for row in M:
    var s: float = 0
    for i in 0..<row.len:
      s += row[i] * v[i]
    result.add(s)

proc toRad*(angle: float): float = angle * PI / 180

proc rotate*(vector: Vector, rx, ry: float): Vector =
  ## Rotates vector over X and Y axis (in degrees)
  let
    rx = rx.toRad
    ry = ry.toRad

    mx: Matrix = @[
      @[1.0, 0.0, 0.0],
      @[0.0, cos(rx), -sin(rx)],
      @[0.0, sin(rx), cos(rx)],
    ]

    my: Matrix = @[
      @[cos(ry), 0, sin(ry)],
      @[0.0, 1.0, 0.0],
      @[-sin(ry), 0, cos(ry)],
    ]

  result = my * (mx * vector)
