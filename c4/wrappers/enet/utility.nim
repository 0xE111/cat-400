template ENET_MAX*(x, y: untyped): untyped =
  (if (x) > (y): (x) else: (y))

template ENET_MIN*(x, y: untyped): untyped =
  (if (x) < (y): (x) else: (y))
