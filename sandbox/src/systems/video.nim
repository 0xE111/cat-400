import logging

import c4.systems
import c4.systems.network.enet
import c4.systems.video.horde3d as horde3d_video
import c4.presets.action.systems.video
import c4.wrappers.horde3d.horde3d


type
  SandboxVideoSystem* = object of ActionVideoSystem
    skybox: horde3d.Node


var
  cubeResource: horde3d.Res
  skyboxResource: horde3d.Res


method init*(self: ref SandboxVideoSystem) =
  procCall ((ref VideoSystem)self).init()
  logging.debug "Loading custom video resources"

  cubeResource = addResource(ResTypes.SceneGraph, "models/cube/cube.scene.xml")
  skyboxResource = addResource(ResTypes.SceneGraph, "models/skybox/skybox.scene.xml")
  if cubeResource == 0 or skyboxResource == 0:
    let msg = "Custom resources not loaded"
    logging.fatal msg
    raise newException(LibraryError, msg)

  self.loadResources()

method initComponent*(self: ref VideoSystem, component: ref Video) =
  component.node = RootNode.addNodes(cubeResource)

method process*(self: ref SandboxVideoSystem, message: ref ConnectionOpenedMessage) =
  ## Load skybox when connection is established
  logging.debug "Loading skybox"

  self.skybox = RootNode.addNodes(skyboxResource)
  self.skybox.setNodeTransform(0, 0, 0, 0, 0, 0, 210, 50, 210)
  self.skybox.setNodeFlags(NodeFlags.NoCastShadow, true)

method process*(self: ref SandboxVideoSystem, message: ref ConnectionClosedMessage) =
  ## Unload everything when connection is closed
  logging.debug "Unloading skybox"

  self.skybox.removeNode()

# method process(self: ref ActionVideoSystem, message: ref CreateEntityMessage) =
#   message.entity[ref Video] = new(CubeVideo)
#   message.entity[ref Video][].init()
