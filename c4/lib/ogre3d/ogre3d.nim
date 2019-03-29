## Basic wrapper for Ogre3d.
## Only minimal requred definitions included.
import unittest
import strformat
import os

when defined(windows):
  raise newException(LibraryError, "Not implemented")

elif defined(macosx):
  raise newException(LibraryError, "Not implemented")

else:
  {.link: "/usr/lib/libOgre.so".}
  {.link: "/usr/lib/libOgreMain.so".}
  {.passC: "-I/usr/include/OGRE".}  # -I/usr/include/OGRE/RTShaderSystem -I/usr/include/OGRE/Bites".}

  const
    pluginsConfig = "/usr/share/OGRE/plugins.cfg"
    mediaDir = "/usr/share/OGRE/Media"


type
  String* {.header: "OgrePrerequisites.h", importcpp: "Ogre::String", bycopy.} = object
  Root* {.header: "OgreRoot.h", importcpp: "Ogre::Root", bycopy.} = object
  RenderWindow* {.header: "OgreRenderWindow.h", importcpp: "Ogre::RenderWindow", bycopy.} = object
  ConfigDialog* {.header: "OgreConfigDialog.h", importcpp: "Ogre::ConfigDialog", bycopy.} = object
  ResourceGroupManager* {.header: "OgreResourceGroupManager.h", importcpp: "Ogre::ResourceGroupManager", bycopy.} = object


var
  DEFAULT_RESOURCE_GROUP_NAME {.header: "OgreResourceGroupManager.h", importcpp: "Ogre::ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME".}: cstring


proc newRoot*(pluginFileName: cstring = pluginsConfig, configFileName: cstring = "ogre.cfg", logFileName: cstring = "ogre.log"): ptr Root {.header: "OgreRoot.h", importcpp: "new Ogre::Root(@)", constructor.}

proc showConfigDialog(this: ptr Root, dialog: ptr ConfigDialog = nil): bool {.header: "OgreRoot.h", importcpp: "#.showConfigDialog(@)".}
proc restoreConfig*(this: ptr Root): bool {.header: "OgreRoot.h", importcpp: "#.restoreConfig(@)".}

proc initialise*(this: ptr Root, autoCreateWindow: bool, windowTitle: cstring = "OGRE Render Window", customCapabilitiesConfig: cstring = ""): ptr RenderWindow {.header: "OgreRoot.h", importcpp: "#.initialise(@)".}
proc getSingletonPtr*(): ptr ResourceGroupManager {.header: "OgreResourceGroupManager.h", importcpp: "Ogre::ResourceGroupManager::getSingletonPtr()".}

proc addResourceLocation*(this: ptr ResourceGroupManager, name: cstring, locType: cstring, resGroup: cstring = DEFAULT_RESOURCE_GROUP_NAME, recursive: bool = false, readOnly: bool = true) {.header: "OgreResourceGroupManager.h", importcpp: "#.addResourceLocation(@)".}

when isMainModule:
  suite "OGRE bindings test":
    test "Base initialization":
      var root = newRoot()

      if not root.restoreConfig() and not root.showConfigDialog():
        raise newException(LibraryError, "Could not load config")

      discard root.initialise(false)

    test "Loading resources":
      var resourceManager: ptr ResourceGroupManager = getSingletonPtr()
      resourceManager.addResourceLocation(mediaDir / "packs" / "SdkTrays.zip", "Zip")
