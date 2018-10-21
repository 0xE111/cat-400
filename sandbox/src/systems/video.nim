import logging
import strformat

import c4/config
import c4/core/entities
import c4/systems
import c4/systems/network/enet
import c4/systems/video/horde3d as horde3d_video
import c4/presets/action/systems/video
import c4/wrappers/horde3d/horde3d
import c4/wrappers/horde3d/horde3d/helpers
import c4/presets/action/messages


type
  SandboxVideoSystem* = object of ActionVideoSystem
    skybox: horde3d.Node

  SandboxVideo* = object of Video


var
  cubeResource: horde3d.Res
  skyboxResource: horde3d.Res

# ---- Component ----
method init*(self: ref SandboxVideo) =
  assert config.systems.video of ref SandboxVideoSystem

  self.node = RootNode.addNodes(cubeResource)


# ---- System ----
method init*(self: ref SandboxVideoSystem) =
  procCall self.as(ref VideoSystem).init()
  logging.debug "Loading custom video resources"

  cubeResource = addResource(ResTypes.SceneGraph, "models/cube/cube.scene.xml")
  skyboxResource = addResource(ResTypes.SceneGraph, "models/skybox/skybox.scene.xml")
  if cubeResource == 0 or skyboxResource == 0:
    let msg = "Custom resources not loaded"
    logging.fatal msg
    raise newException(LibraryError, msg)

  self.loadResources()

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

method process*(self: ref SandboxVideoSystem, message: ref CreateEntityMessage) =
  logging.debug &"Creating video component for {message.entity}"
  message.entity[ref Video] = SandboxVideo.new()
