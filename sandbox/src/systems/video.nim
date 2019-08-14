import logging
import strformat
import tables

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

  self.sceneManager.setAmbientLight(initColourValue(0.5, 0.5, 0.5))

  var light = self.sceneManager.createLight("MainLight");
  light.setPosition(20.0, 80.0, 50.0);

method process*(self: ref SandboxVideoSystem, message: ref ConnectionOpenedMessage) =
  ## Load skybox when connection is established
  logging.debug "Loading skybox"


method process*(self: ref SandboxVideoSystem, message: ref ConnectionClosedMessage) =
  ## Unload everything when connection is closed
  logging.debug "Unloading skybox"

  # self.skybox.removeNode()
