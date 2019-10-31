import logging
import os

import c4/systems
import c4/systems/network/enet
import c4/systems/video/ogre as ogre_video
import c4/lib/ogre/ogre
import c4/presets/action/systems/video
import c4/utils/stringify


type
  SandboxVideoSystem* = object of ActionVideoSystem

  BoxVideo* = object of Video
  PlaneVideo* = object of Video


# ---- Component ----
method init*(self: ref SandboxVideoSystem, video: ref BoxVideo) =
  procCall self.as(ref ActionVideoSystem).init(video)
  video.node.attachObject(self.sceneManager.createEntity("box"))

method init*(self: ref SandboxVideoSystem, video: ref PlaneVideo) =
  procCall self.as(ref ActionVideoSystem).init(video)
  video.node.attachObject(self.sceneManager.createEntity("plane"))


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

  self.camera.setNearClipDistance(0.01)
  self.sceneManager.setAmbientLight(initColourValue(0.5, 0.5, 0.5))

  let light = self.sceneManager.createLight("MainLight")
  light.setPosition(20.0, 80.0, 50.0)

  # ---- draw axis ----
  let axisObject = self.sceneManager.createManualObject()
  axisObject.begin("BaseWhiteNoLighting", OT_LINE_LIST)

  # X axis, red
  axisObject.position(0, 0, 0)
  axisObject.colour(1, 0, 0)
  axisObject.position(100, 0, 0)

  # Y axis, green
  axisObject.position(0, 0, 0)
  axisObject.colour(0, 1, 0)
  axisObject.position(0, 100, 0)

  # Z axis, blue
  axisObject.position(0, 0, 0)
  axisObject.colour(0, 0, 1)
  axisObject.position(0, 0, 100)

  discard axisObject.end()
  discard axisObject.convertToMesh("axis")

  let axis = self.sceneManager.createEntity("axis")
  self.sceneManager.getRootSceneNode().createChildSceneNode().attachObject(axis)

  # ---- create box mesh ----
  let boxObject = self.sceneManager.createManualObject()

  boxObject.begin("BaseWhiteNoLighting", OT_TRIANGLE_LIST)

  # front
  boxObject.position(-0.5, -0.5, 0.5)
  boxObject.colour(0, 0, 0.75)
  boxObject.position(0.5, -0.5, 0.5)
  boxObject.position(0.5, 0.5, 0.5)
  boxObject.position(-0.5, 0.5, 0.5)
  boxObject.quad(0, 1, 2, 3)

  # back
  boxObject.position(-0.5, 0.5, -0.5)
  boxObject.position(0.5, 0.5, -0.5)
  boxObject.position(0.5, -0.5, -0.5)
  boxObject.position(-0.5, -0.5, -0.5)
  boxObject.quad(4, 5, 6, 7)

  # right
  boxObject.position(0.5, -0.5, 0.5)
  boxObject.colour(0.75, 0, 0)
  boxObject.position(0.5, -0.5, -0.5)
  boxObject.position(0.5, 0.5, -0.5)
  boxObject.position(0.5, 0.5, 0.5)
  boxObject.quad(8, 9, 10, 11)

  # left
  boxObject.position(-0.5, -0.5, -0.5)
  boxObject.position(-0.5, -0.5, 0.5)
  boxObject.position(-0.5, 0.5, 0.5)
  boxObject.position(-0.5, 0.5, -0.5)
  boxObject.quad(12, 13, 14, 15)

  # bottom
  boxObject.position(-0.5, -0.5, -0.5)
  boxObject.colour(0, 0.75, 0)
  boxObject.position(0.5, -0.5, -0.5)
  boxObject.position(0.5, -0.5, 0.5)
  boxObject.position(-0.5, -0.5, 0.5)
  boxObject.quad(16, 17, 18, 19)

  # up
  boxObject.position(-0.5, 0.5, 0.5)
  boxObject.position(0.5, 0.5, 0.5)
  boxObject.position(0.5, 0.5, -0.5)
  boxObject.position(-0.5, 0.5, -0.5)
  boxObject.quad(20, 21, 22, 23)

  discard boxObject.end()

  discard boxObject.convertToMesh("box")

  # ---- plane ----
  let planeObject = self.sceneManager.createManualObject()

  planeObject.begin("BaseWhiteNoLighting", OT_TRIANGLE_LIST)

  planeObject.position(-50, 0, 50)
  planeObject.colour(0.75, 0.75, 0.75)
  planeObject.position(50, 0, 50)
  planeObject.position(50, 0, -50)
  planeObject.position(-50, 0, -50)
  planeObject.quad(0, 1, 2, 3)

  discard planeObject.end()
  discard planeObject.convertToMesh("plane")


method process*(self: ref SandboxVideoSystem, message: ref SystemReadyMessage) =
  # connect to server as soon as video system is loaded
  (ref ConnectMessage)(address: ("localhost", 11477'u16)).send("network")


method process*(self: ref SandboxVideoSystem, message: ref SystemQuitMessage) =
  # disconnect as soon as video system is unloaded
  new(DisconnectMessage).send("network")


method process*(self: ref SandboxVideoSystem, message: ref ConnectionOpenedMessage) =
  ## Load skybox when connection is established
  logging.debug "Loading skybox"


method process*(self: ref SandboxVideoSystem, message: ref ConnectionClosedMessage) =
  ## Unload everything when connection is closed
  logging.debug "Unloading skybox"

  # self.skybox.removeNode()
