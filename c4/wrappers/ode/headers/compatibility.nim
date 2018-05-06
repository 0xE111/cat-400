template dQtoR*(q, R: untyped): untyped =
  dRfromQ((R), (q))

template dRtoQ*(R, q: untyped): untyped =
  dQfromR((q), (R))

template dWtoDQ*(w, q, dq: untyped): untyped =
  dDQfromW((dq), (w), (q))
