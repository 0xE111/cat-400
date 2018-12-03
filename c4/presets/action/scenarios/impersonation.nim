import ../../../config
import ../../../systems
import ../../../systems/network/enet

import ../messages
import ../systems/network
import ../systems/video


method process*(self: ref ActionNetworkSystem, message: ref ImpersonationMessage) =
  ## When server tells client to occupy some entity, send this message to video system
  assert mode == client

  procCall self.as(ref NetworkSystem).process(message)
  message.send(config.systems.video)


method process*(self: ref ActionVideoSystem, message: ref ImpersonationMessage) =
  ## Attach camera to impersonated entity


# method process(self: ref ActionVideoSystem, message: ref PlayerRotateMessage) =
#     let curTransform = self.camera.getTransform()

#     self.camera.setNodeTransform(
#       curTransform.tx, curTransform.ty, curTransform.tz,
#       (curTransform.rx - (message.pitch / 8).cfloat).max(-85).min(85),  # here we limit camera pitch
#       curTransform.ry - (message.yaw / 8).cfloat,
#       curTransform.rz,
#       curTransform.sx, curTransform.sy, curTransform.sz,
#     )