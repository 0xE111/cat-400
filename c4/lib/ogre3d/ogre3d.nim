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


type
  String* {.header: "OgrePrerequisites.h", importcpp: "Ogre::String", bycopy.} = object
  Root* {.header: "OgreRoot.h", importcpp: "Ogre::Root", bycopy.} = object

var
  OGRE_BUILD_SUFFIX {.header: "OgrePlatform.h", importcpp: "OGRE_BUILD_SUFFIX".}: cstring


proc newRoot*(pluginFileName: cstring = &"plugins{OGRE_BUILD_SUFFIX}.cfg", configFileName: cstring = "ogre.cfg", logFileName: cstring = "Ogre.log"): ptr Root {.header: "OgreRoot.h", importcpp: "new Ogre::Root(@)", constructor.}


when isMainModule:
  suite "OGRE bindings test":
    test "Const reading":
      echo &"OGRE_BUILD_SUFFIX: '{OGRE_BUILD_SUFFIX}'"

    test "Base initialization":
      discard newRoot(logFileName="test.log")

