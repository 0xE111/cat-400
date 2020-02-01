import logging
import os

import c4/sugar
import c4/lib/ogre/ogre as ogrelib
import c4/systems/video/ogre
import c4/threads


type
  VideoSystem* = object of OgreVideoSystem
    playerNode*: ptr SceneNode

  BoxVideo* = object of OgreVideo
  PlaneVideo* = object of OgreVideo


method init*(self: ref VideoSystem, video: ref BoxVideo) =
  procCall self.as(ref OgreVideoSystem).init(video)
  video.node.attachObject(self.sceneManager.createEntity("box"))


method init*(self: ref VideoSystem, video: ref PlaneVideo) =
  procCall self.as(ref OgreVideoSystem).init(video)
  video.node.attachObject(self.sceneManager.createEntity("plane"))


proc init*(self: ref VideoSystem) =
  procCall self.as(ref OgreVideoSystem).init()
  logging.debug "Loading custom video resources"

  operateOn self.resourceManager:
    addResourceLocation(defaultMediaDir / "packs" / "SdkTrays.zip", "Zip", resGroup="Essential")
    addResourceLocation(defaultMediaDir, "FileSystem", resGroup="General")
    addResourceLocation(defaultMediaDir / "models", "FileSystem", resGroup="General")
    addResourceLocation(defaultMediaDir / "materials" / "programs" / "Cg", "FileSystem", resGroup="General")
    addResourceLocation(defaultMediaDir / "materials" / "programs" / "GLSL", "FileSystem", resGroup="General")
    addResourceLocation(defaultMediaDir / "materials" / "programs" / "GLSL120", "FileSystem", resGroup="General")
    addResourceLocation(defaultMediaDir / "materials" / "programs" / "GLSL150", "FileSystem", resGroup="General")
    addResourceLocation(defaultMediaDir / "materials" / "programs" / "GLSL400", "FileSystem", resGroup="General")
    addResourceLocation(defaultMediaDir / "materials" / "programs" / "HLSL", "FileSystem", resGroup="General")
    addResourceLocation(defaultMediaDir / "materials" / "programs" / "HLSL_Cg", "FileSystem", resGroup="General")
    addResourceLocation(defaultMediaDir / "materials" / "scripts", "FileSystem", resGroup="General")
    addResourceLocation(defaultMediaDir / "materials" / "textures", "FileSystem", resGroup="General")
    initialiseAllResourceGroups()

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

  operateOn boxObject:
    begin("BaseWhiteNoLighting", OT_TRIANGLE_LIST)

    # front
    position(-0.5, -0.5, 0.5)
    colour(0, 0, 0.75)
    position(0.5, -0.5, 0.5)
    position(0.5, 0.5, 0.5)
    position(-0.5, 0.5, 0.5)
    quad(0, 1, 2, 3)

    # back
    position(-0.5, 0.5, -0.5)
    position(0.5, 0.5, -0.5)
    position(0.5, -0.5, -0.5)
    position(-0.5, -0.5, -0.5)
    quad(4, 5, 6, 7)

    # right
    position(0.5, -0.5, 0.5)
    colour(0.75, 0, 0)
    position(0.5, -0.5, -0.5)
    position(0.5, 0.5, -0.5)
    position(0.5, 0.5, 0.5)
    quad(8, 9, 10, 11)

    # left
    position(-0.5, -0.5, -0.5)
    position(-0.5, -0.5, 0.5)
    position(-0.5, 0.5, 0.5)
    position(-0.5, 0.5, -0.5)
    quad(12, 13, 14, 15)

    # bottom
    position(-0.5, -0.5, -0.5)
    colour(0, 0.75, 0)
    position(0.5, -0.5, -0.5)
    position(0.5, -0.5, 0.5)
    position(-0.5, -0.5, 0.5)
    quad(16, 17, 18, 19)

    # up
    position(-0.5, 0.5, 0.5)
    position(0.5, 0.5, 0.5)
    position(0.5, 0.5, -0.5)
    position(-0.5, 0.5, -0.5)
    quad(20, 21, 22, 23)

  discard boxObject.end()
  discard boxObject.convertToMesh("box")

  # ---- plane ----
  let planeObject = self.sceneManager.createManualObject()

  operateOn planeObject:
    begin("BaseWhiteNoLighting", OT_TRIANGLE_LIST)

    position(-50, 0.float, 50)
    colour(0.0, 1.0, 1.0)
    position(50, 0.float, 50)
    colour(1.0, 1.0, 1.0)
    position(50, 0.float, -50)
    colour(1.0, 0.0, 0.0)
    position(-50, 0.float, -50)
    colour(0.0, 0.0, 0.0)
    quad(0, 1, 2, 3)

  discard planeObject.end()
  discard planeObject.convertToMesh("plane")
