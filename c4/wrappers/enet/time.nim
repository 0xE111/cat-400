const
  ENET_TIME_OVERFLOW* = 86400000

template ENET_TIME_LESS*(a, b: untyped): untyped =
  ((a) - (b) >= ENET_TIME_OVERFLOW)

template ENET_TIME_GREATER*(a, b: untyped): untyped =
  ((b) - (a) >= ENET_TIME_OVERFLOW)

template ENET_TIME_LESS_EQUAL*(a, b: untyped): untyped =
  (not ENET_TIME_GREATER(a, b))

template ENET_TIME_GREATER_EQUAL*(a, b: untyped): untyped =
  (not ENET_TIME_LESS(a, b))

template ENET_TIME_DIFFERENCE*(a, b: untyped): untyped =
  (if (a) - (b) >= ENET_TIME_OVERFLOW: (b) - (a) else: (a) - (b))
