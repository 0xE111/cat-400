import sdl2

import c4/lib/ogre/ogre as libogre
import c4/systems/video/ogre
import c4/sugar


type
  VideoSystem* = object of ogre.VideoSystem

  Video* = object of RootObj
    node*: ptr SceneNode


proc drawAxis*(self: ref VideoSystem) =
  let axisObject = self.sceneManager.createManualObject()
  axisObject.begin("BaseWhiteNoLighting", OT_LINE_LIST)

  # X axis, red
  for z in -10..10:
    axisObject.position(-10.0, 0.0, z.float)
    axisObject.colour(if z == 0: 1.0 else: 0.5, 0, 0)
    axisObject.position(10.0, 0.0, z.float)

  # Y axis, green
  axisObject.position(0, 0, 0)
  axisObject.colour(0, 1, 0)
  axisObject.position(0, 100, 0)

  # Z axis, blue
  for x in -10..10:
    axisObject.position(x.float, 0.0, -10.0)
    axisObject.colour(0, 0, if x == 0: 1.0 else: 0.5)
    axisObject.position(x.float, 0.0, 10.0)

  discard axisObject.end()
  discard axisObject.convertToMesh("axis")

  let axis = self.sceneManager.createEntity("axis")
  self.sceneManager.getRootSceneNode().createChildSceneNode().attachObject(axis)


proc createBoxMesh(self: ref VideoSystem) =

  let boxObject = self.sceneManager.createManualObject()
  let size = 0.1

  operateOn boxObject:
    begin("BaseWhiteNoLighting", OT_TRIANGLE_LIST)

    # front
    position(-size/2, -size/2, size/2)
    colour(0, 0, 0.75)
    position(size/2, -size/2, size/2)
    position(size/2, size/2, size/2)
    position(-size/2, size/2, size/2)
    quad(0, 1, 2, 3)

    # back
    position(-size/2, size/2, -size/2)
    position(size/2, size/2, -size/2)
    position(size/2, -size/2, -size/2)
    position(-size/2, -size/2, -size/2)
    quad(4, 5, 6, 7)

    # right
    position(size/2, -size/2, size/2)
    colour(0.75, 0, 0)
    position(size/2, -size/2, -size/2)
    position(size/2, size/2, -size/2)
    position(size/2, size/2, size/2)
    quad(8, 9, 10, 11)

    # left
    position(-size/2, -size/2, -size/2)
    position(-size/2, -size/2, size/2)
    position(-size/2, size/2, size/2)
    position(-size/2, size/2, -size/2)
    quad(12, 13, 14, 15)

    # bottom
    position(-size/2, -size/2, -size/2)
    colour(0, 0.75, 0)
    position(size/2, -size/2, -size/2)
    position(size/2, -size/2, size/2)
    position(-size/2, -size/2, size/2)
    quad(16, 17, 18, 19)

    # up
    position(-size/2, size/2, size/2)
    position(size/2, size/2, size/2)
    position(size/2, size/2, -size/2)
    position(-size/2, size/2, -size/2)
    quad(20, 21, 22, 23)

  discard boxObject.end()
  discard boxObject.convertToMesh("box")


method process*(self: ref VideoSystem, message: ref ogre.VideoInitMessage) =
  procCall self.as(ref ogre.VideoSystem).process(message)

  discard setRelativeMouseMode(True32)

  self.camera.setNearClipDistance(0.01)
  self.sceneManager.setAmbientLight(initColourValue(0.5, 0.5, 0.5))

  self.drawAxis()
  self.createBoxMesh()
