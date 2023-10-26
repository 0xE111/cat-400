import math

import c4/lib/ode/ode


type Quaternion* = array[4, float]  # w, x, y, z


proc eulFromR*(r: dMatrix3): tuple[z, y, x: float] =
  # ZYXr case only
  let cy = sqrt(r[0] * r[0] + r[4] * r[4])
  if cy > 16 * 0.000002:
    result.x = arctan2(r[9], r[10])
    result.y = arctan2(-r[8], cy)
    result.z = arctan2(r[4], r[0])
  else:
    result.x = arctan2(-r[6], r[5])
    result.y = arctan2(-r[8], cy)
    result.z = 0


proc eulFromQ*(q: dQuaternion): tuple[z, y, x: float] =
  # ZYXr case only

  # get rotation matrix
  var m: dMatrix3
  m.rfromQ(q)

  eulFromR(m)


proc getPitchYaw*(q: dQuaternion): tuple[yaw: float, pitch: float] =
  ## Convert quaternion as only yaw and pitch rotations

  # rotation in Euler angles
  let eul = q.eulFromQ()

  # get current yaw & pitch (as if it was without roll)
  let flip: bool = not(abs(eul.z) <= 0.001)

  result.yaw = if not flip: eul.y else: PI - eul.y
  result.pitch = if not flip: eul.x else: eul.x + (if eul.x < 0: PI else: -PI)
