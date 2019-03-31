## Basic wrapper for Ogre3d.
## Only minimal requred definitions included.
import unittest
import strformat
import os

when isMainModule:
  # some modules required for unit testing
  import sdl2/sdl, sdl2/sdl_syswm

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
  StdMap[K, V] {.header: "<map>", importcpp: "std::map".} = object
  String* {.header: "OgrePrerequisites.h", importcpp: "Ogre::String", bycopy.} = object
  # String* {.header: "<string>", importcpp: "std::string", bycopy.} = object
  Root* {.header: "OgreRoot.h", importcpp: "Ogre::Root", bycopy.} = object
  RenderWindow* {.header: "OgreRenderWindow.h", importcpp: "Ogre::RenderWindow", bycopy.} = object
  ConfigDialog* {.header: "OgreConfigDialog.h", importcpp: "Ogre::ConfigDialog", bycopy.} = object
  ResourceGroupManager* {.header: "OgreResourceGroupManager.h", importcpp: "Ogre::ResourceGroupManager", bycopy.} = object
  NameValuePairList* = StdMap[String, String]


var
  DEFAULT_RESOURCE_GROUP_NAME {.header: "OgreResourceGroupManager.h", importcpp: "Ogre::ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME".}: cstring

proc `[]=`*[K, V](this: var StdMap[K, V]; key: K; val: V) {.importcpp: "#[#] = #", header: "<map>".}
proc toString*[T](value: T): String {.importcpp: "std::to_string(@)".}
proc c_str*(value: String): cstring {.importcpp: "#.c_str()".}
proc initString*(value: cstring): String {.header: "OgrePrerequisites.h", importcpp: "Ogre::String(@)".}
# proc initNameValuePairList*: NameValuePairList {.headerimportcpp: "NameValuePairList()".}

proc newRoot*(pluginFileName: cstring = pluginsConfig, configFileName: cstring = "ogre.cfg", logFileName: cstring = "ogre.log"): ptr Root {.header: "OgreRoot.h", importcpp: "new Ogre::Root(@)", constructor.}
# proc newRenderWindow*(): ptr RenderWindow {.header: "OgreRenderWindow.h", importcpp: "new(Ogre::RenderWindow)", constructor.}
proc createRenderWindow(this: ptr Root, name: cstring, width: uint, height: uint, fullScreen: bool, miscParams: ptr NameValuePairList = nil): ptr RenderWindow {.header: "OgreRoot.h", importcpp: "#.createRenderWindow(@)".}


proc showConfigDialog(this: ptr Root, dialog: ptr ConfigDialog = nil): bool {.header: "OgreRoot.h", importcpp: "#.showConfigDialog(@)".}
proc restoreConfig*(this: ptr Root): bool {.header: "OgreRoot.h", importcpp: "#.restoreConfig(@)".}

proc initialise*(this: ptr Root, autoCreateWindow: bool, windowTitle: cstring = "OGRE Render Window", customCapabilitiesConfig: cstring = ""): ptr RenderWindow {.header: "OgreRoot.h", importcpp: "#.initialise(@)".}
proc getSingletonPtr*(): ptr ResourceGroupManager {.header: "OgreResourceGroupManager.h", importcpp: "Ogre::ResourceGroupManager::getSingletonPtr()".}

proc addResourceLocation*(this: ResourceGroupManager, name: cstring, locType: cstring, resGroup: cstring = DEFAULT_RESOURCE_GROUP_NAME, recursive: bool = false, readOnly: bool = true) {.header: "OgreResourceGroupManager.h", importcpp: "#.addResourceLocation(@)".}

when isMainModule:
  suite "OGRE bindings test":
    var root = newRoot()
    test "Configuration":
      # TODO:
      # proc getAvailableRenderers*(this: ptr Root):
      # Once you have a pointer to the RenderSystem, you can use RenderSystem::getConfigOptions to see what options it provides.
      # RenderSystem* rs = mRoot->getRenderSystemByName("Direct3D9 Rendering Subsystem");

      # mRoot->setRenderSystem(rs);
      # rs->setConfigOption("Full Screen", "No");
      # rs->setConfigOption("Video Mode", "800 x 600 @ 32-bit colour");

      if not root.restoreConfig() and not root.showConfigDialog():
        raise newException(LibraryError, "Could not load config")

    test "Init SDL+Ogre3d":
      if sdl.initSubSystem(sdl.INIT_VIDEO) != 0:
        raise newException(LibraryError, "Could not init SDL video subsystem")

      var window = sdl.createWindow(
        "Ogre3d test", 100, 100, 800, 600,
        (sdl.WINDOW_SHOWN or sdl.WINDOW_OPENGL or sdl.WINDOW_RESIZABLE).uint32,  # TODO: do we need WINDOW_OPENGL for other backends?
      )
      if window == nil:
        raise newException(LibraryError, "Could not create SDL window")

      if sdl.setRelativeMouseMode(true) != 0:
        raise newException(LibraryError, "Could not enable relative mouse mode")

      # get native window handle
      var info: sdl_syswm.SysWMinfo
      sdl.version(info.version)
      assert sdl_syswm.getWindowWMInfo(window, info.addr)
      var nativeWindowHandle = info.info.x11.window  # culong

      # when defined(SDL_VIDEO_DRIVER_WINDOWS):
      #   nativeWindowHandle = cast[pointer](info.info.win.window)

      # elif defined(SDL_VIDEO_DRIVER_X11):
      #   nativeWindowHandle = cast[pointer](info.info.x11.window)

      # elif defined(SDL_VIDEO_DRIVER_COCOA):
      #   nativeWindowHandle = cast[pointer](info.info.cocoa.window)

      # else:
      #   raise newException(LibraryError, "SDL video driver undefined")

      echo ">>>"
      echo $nativeWindowHandle
      echo nativeWindowHandle.toString().c_str()
      echo ">>>"

      discard root.initialise(false)

      var misc: NameValuePairList
      misc[initString("externalWindowHandle")] = nativeWindowHandle.toString()

      var renderWindow = root.createRenderWindow("Main Render Window", 800, 600, false, misc.addr)

    # test "Loading resources":
    #   var resourceManager: ptr ResourceGroupManager = getSingletonPtr()
    #   resourceManager[].addResourceLocation(mediaDir / "packs" / "SdkTrays.zip", "Zip", resGroup="Essential")

    #   resourceManager[].addResourceLocation(mediaDir, "FileSystem", resGroup="General")
    #   resourceManager[].addResourceLocation(mediaDir / "models", "FileSystem", resGroup="General")
    #   resourceManager[].addResourceLocation(mediaDir / "materials" / "scripts", "FileSystem", resGroup="General")
    #   resourceManager[].addResourceLocation(mediaDir / "materials" / "textures", "FileSystem", resGroup="General")