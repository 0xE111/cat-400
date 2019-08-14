# systems/video.nim
import logging
import os  # required for `/` proc

import c4/systems
import c4/systems/video/ogre
# in order to use ogre bindings like `self.resourceManager.addResourceLocation`, we have to import `c4/lib/ogre/ogre` module; to avoid name clash with `c4/systems/video/ogre`, we use `import ... as ...`
import c4/lib/ogre/ogre as ogre_lib

type CustomVideoSystem* = object of VideoSystem

method init(self: ref CustomVideoSystem) =
  # call base method, which will perform default initialization
  procCall self.as(ref VideoSystem).init()

  # write something to ensure custom `init()` is called
  logging.debug "Initializing custom video system"

  logging.debug "Loading custom video resources"

  self.resourceManager.addResourceLocation(defaultMediaDir / "packs" / "SdkTrays.zip", "Zip", resGroup="Essential")
  self.resourceManager.addResourceLocation(defaultMediaDir, "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(defaultMediaDir / "models", "FileSystem", resGroup="General")
  # self.resourceManager.addResourceLocation(defaultMediaDir / "materials" / "scripts", "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(defaultMediaDir / "materials" / "textures", "FileSystem", resGroup="General")
  self.resourceManager.initialiseAllResourceGroups()
