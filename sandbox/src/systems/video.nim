import logging
import strformat
import tables
import os
import math

import c4/entities
import c4/systems
import c4/systems/network/enet
import c4/systems/video/ogre as ogre_video
import c4/lib/ogre/ogre
import c4/presets/action/systems/video
import c4/presets/action/messages
import c4/utils/stringify


type
  SandboxVideoSystem* = object of ActionVideoSystem

  SandboxVideo* = object of Video


# ---- Component ----
method attach*(self: ref SandboxVideo) =
  procCall self.as(ref Video).attach()
  let videoSystem = systems.get("video").as(ref SandboxVideoSystem)
  let entity = videoSystem.sceneManager.createEntity("ogrehead.mesh")
  self.node.attachObject(entity)


# ---- System ----
strMethod(SandboxVideoSystem, fields=false)

method init*(self: ref SandboxVideoSystem) =
  procCall self.as(ref VideoSystem).init()
  logging.debug "Loading custom video resources"

  self.resourceManager.addResourceLocation(defaultMediaDir / "packs" / "SdkTrays.zip", "Zip", resGroup="Essential")
  self.resourceManager.addResourceLocation(defaultMediaDir, "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(defaultMediaDir / "models", "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(defaultMediaDir / "materials" / "programs" / "Cg", "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(defaultMediaDir / "materials" / "programs" / "GLSL", "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(defaultMediaDir / "materials" / "programs" / "GLSL120", "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(defaultMediaDir / "materials" / "programs" / "GLSL150", "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(defaultMediaDir / "materials" / "programs" / "GLSL400", "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(defaultMediaDir / "materials" / "programs" / "HLSL", "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(defaultMediaDir / "materials" / "programs" / "HLSL_Cg", "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(defaultMediaDir / "materials" / "scripts", "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(defaultMediaDir / "materials" / "textures", "FileSystem", resGroup="General")
  self.resourceManager.initialiseAllResourceGroups()

  self.sceneManager.setAmbientLight(initColourValue(0.5, 0.5, 0.5))

  let light = self.sceneManager.createLight("MainLight")
  light.setPosition(20.0, 80.0, 50.0)

  var manualObject = self.sceneManager.createManualObject()
  manualObject[].begin("BaseWhiteNoLighting", OT_LINE_LIST)
  
  manualObject[].position(0, 0, 0)
  manualObject[].position(0, 0, -300)
  discard manualObject[].end()

  var node = self.sceneManager.getRootSceneNode().createChildSceneNode()
  node.attachObject(manualObject)

method process*(self: ref SandboxVideoSystem, message: ref ConnectionOpenedMessage) =
  ## Load skybox when connection is established
  logging.debug "Loading skybox"


method process*(self: ref SandboxVideoSystem, message: ref ConnectionClosedMessage) =
  ## Unload everything when connection is closed
  logging.debug "Unloading skybox"

  # self.skybox.removeNode()
