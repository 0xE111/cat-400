## Basic wrapper for Ogre3d.
## Only minimal requred definitions included.
import unittest
import strformat

when defined(windows):
  raise newException(LibraryError, "Not implemented")

elif defined(macosx):
  raise newException(LibraryError, "Not implemented")

else:
  {.link: "/usr/lib/libOgre.so".}
  {.link: "/usr/lib/libOgreMain.so".}
  {.passC: "-I/usr/include/OGRE".}  # -I/usr/include/OGRE/RTShaderSystem -I/usr/include/OGRE/Bites".}
  const pluginsConfig = "/usr/share/OGRE/plugins.cfg"


type
  String* {.header: "OgrePrerequisites.h", importcpp: "Ogre::String", bycopy.} = object
  Root* {.header: "OgreRoot.h", importcpp: "Ogre::Root", bycopy.} = object
  RenderWindow* {.header: "OgreRenderWindow.h", importcpp: "Ogre::RenderWindow", bycopy.} = object
  ConfigDialog* {.header: "OgreConfigDialog.h", importcpp: "Ogre::ConfigDialog", bycopy.} = object


# var
#   OGRE_BUILD_SUFFIX {.header: "OgrePlatform.h", importcpp: "OGRE_BUILD_SUFFIX".}: cstring


proc newRoot*(
  pluginFileName: cstring = pluginsConfig,
  configFileName: cstring = "ogre.cfg",
  logFileName: cstring = "ogre.log"
): ptr Root {.header: "OgreRoot.h", importcpp: "new Ogre::Root(@)", constructor.}

proc showConfigDialog(this: ptr Root, dialog: ptr ConfigDialog = nil): bool {.header: "OgreRoot.h", importcpp: "#.showConfigDialog(@)".}
proc restoreConfig*(this: ptr Root): bool {.header: "OgreRoot.h", importcpp: "#.restoreConfig(@)".}

# RenderWindow* initialise(bool autoCreateWindow, const String& windowTitle = "OGRE Render Window", const String& customCapabilitiesConfig = BLANKSTRING);
proc initialise*(
  this: ptr Root,
  autoCreateWindow: bool,
  windowTitle: cstring = "OGRE Render Window",
  customCapabilitiesConfig: cstring = "",
): ptr RenderWindow {.header: "OgreRoot.h", importcpp: "#.initialise(@)".}


when isMainModule:
  suite "OGRE bindings test":
    test "Base initialization":
      var root = newRoot(pluginFileName="plugins.cfg", configFileName="ogre.cfg", logFileName="ogre.log")

      if not root.restoreConfig() and not root.showConfigDialog():
        raise newException(LibraryError, "Could not load config")

      discard root.initialise(false)
