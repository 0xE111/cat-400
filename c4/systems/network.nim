type
  NetworkSystem* = object of RootObj


method init*(self: ref NetworkSystem) =
  doAssert(false, "NetworkSystem.init not implemented")

method update*(self: ref NetworkSystem, dt: float): bool =
  doAssert(false, "NetworkSystem.update not implemented")
