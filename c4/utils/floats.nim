

proc `==`*(a, b: float): bool {.inline.} =
  (a - b).abs <= 0.01

proc `!=`*(a, b: float): bool {.inline.} = not (a == b)
