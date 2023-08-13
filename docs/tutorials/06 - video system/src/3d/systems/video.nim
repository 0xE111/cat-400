import std/math
import std/times

import c4/logging
import c4/systems/video/ogre
import c4/lib/ogre/ogre
import c4/messages
import c4/entities
import c4/sugar
import c4/threads

import ../messages
import ../consts

type
  VideoSystem* = object of OgreVideoSystem
    entity*: entities.Entity
  Video* = object of OgreVideo


method update*(self: ref VideoSystem, dt: float) =
  ((ref RotateEntityMessage)(angle: sin(epochTime()))).send(videoThread)
  procCall self.as(ref OgreVideoSystem).update(dt)


method process*(self: ref VideoSystem, message: ref OgreVideoInitMessage) =
  procCall self.as(ref OgreVideoSystem).process(message)

  var cameraNode = self.sceneManager.getRootSceneNode().createChildSceneNode()
  cameraNode.attachObject(self.camera)
  cameraNode.setPosition(0.0, 0.0, 0.0)
  cameraNode.lookAt(targetPoint=Vector3(x: 0.0, y: 0.0, z: -300.0), relativeTo=TS_LOCAL)

  self.sceneManager.setAmbientLight(initColourValue(0.5, 0.5, 0.5))

  var light = self.sceneManager.createLight("MainLight");
  var lightNode = self.sceneManager.getRootSceneNode().createChildSceneNode()
  lightNode.attachObject(light)
  lightNode.setPosition(20.0, 80.0, 50.0)

  withLog(DEBUG, "loading resources"):
    let mediaDir = "/usr/share/OGRE-14.0/Media"
    self.resourceGroupManager.addResourceLocation(cstring(mediaDir & "/packs/SdkTrays.zip"), "Zip", resGroup="Essential")
    self.resourceGroupManager.addResourceLocation(cstring(mediaDir & "/models"), "FileSystem", resGroup="General")
    self.resourceGroupManager.addResourceLocation(cstring(mediaDir & "/materials/textures"), "FileSystem", resGroup="General")
    self.resourceGroupManager.addResourceLocation(cstring(mediaDir & "/materials/scripts"), "FileSystem", resGroup="General")
    self.resourceGroupManager.initialiseAllResourceGroups()


method process*(self: ref VideoSystem, message: ref CreateEntityMessage) =
  var node = self.sceneManager.getRootSceneNode().createChildSceneNode()
  node.setPosition(message.x.Real, message.y.Real, message.z.Real)

  var mesh = self.sceneManager.createEntity("ogrehead.mesh")
  if mesh.isNil:
    fatal "mesh loading failure"
    return

  node.attachObject(mesh)

  self.entity = newEntity()
  self.entity[Video] = Video(node: node)


method process*(self: ref VideoSystem, message: ref RotateEntityMessage) =
  self.entity[Video].node.yaw(initRadian(message.angle.Real / 4))
