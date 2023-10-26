import c4/lib/ogre/ogre as libogre
import c4/systems/video/ogre
import c4/sugar


type
  VideoSystem* = object of ogre.VideoSystem
    boxMesh*: MeshPtr

  Video* = object of RootObj
    node*: ptr SceneNode


proc drawAxis*(self: ref VideoSystem) =
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


proc createBoxMesh(self: ref VideoSystem) =

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
  self.boxMesh = boxObject.convertToMesh("box")


method process*(self: ref VideoSystem, message: ref VideoInitMessage) =
  procCall self.as(ref ogre.VideoSystem).process(message)

  self.camera.setNearClipDistance(0.01)
  self.sceneManager.setAmbientLight(initColourValue(0.5, 0.5, 0.5))

  self.drawAxis()
  self.createBoxMesh()
