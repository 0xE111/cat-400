import ../ode


proc getPosition*(self: dBodyID): tuple[x, y, z: float] =
  let position = self.bodyGetPosition()[]
  result = (x: position[0], y: position[1], z: position[2])

# proc getRotation*(self: dBodyID): tuple[pitch, yaw: float] =
#   let rotationMatrix = self.bodyGetRotation()[]
