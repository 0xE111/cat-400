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
  RenderWindow* {.header: "OgreRenderWindow.h", importcpp: "Ogre::RenderWindow", bycopy.} = object
  ConfigDialog* {.header: "OgreConfigDialog.h", importcpp: "Ogre::ConfigDialog", bycopy.} = object
  NameValuePairList* = StdMap[String, String]

when defined(OGRE_DOUBLE_PRECISION):
  type Real* = float64
else:
  type Real* = float32


proc `[]=`*[K, V](this: var StdMap[K, V]; key: K; val: V) {.importcpp: "#[#] = #", header: "<map>".}
proc toString*[T](value: T): String {.importcpp: "std::to_string(@)".}
proc c_str*(value: String): cstring {.importcpp: "#.c_str()".}
proc initString*(value: cstring): String {.header: "OgrePrerequisites.h", importcpp: "Ogre::String(@)".}
# proc initNameValuePairList*: NameValuePairList {.headerimportcpp: "NameValuePairList()".}

# {.push header: "OgreVector.h".}

# {.pop.}


# proc newRenderWindow*(): ptr RenderWindow {.header: "OgreRenderWindow.h", importcpp: "new(Ogre::RenderWindow)", constructor.}

{.push header: "OgreResourceGroupManager.h".}
type
  ResourceGroupManager* {.importcpp: "Ogre::ResourceGroupManager", bycopy.} = object

var
  DEFAULT_RESOURCE_GROUP_NAME {.importcpp: "Ogre::ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME".}: cstring

proc getSingletonPtr*(): ptr ResourceGroupManager {.importcpp: "Ogre::ResourceGroupManager::getSingletonPtr()".}

{.push importcpp: "#.$1(@)".}
proc addResourceLocation*(this: ptr ResourceGroupManager, name: cstring, locType: cstring, resGroup: cstring = DEFAULT_RESOURCE_GROUP_NAME, recursive: bool = false, readOnly: bool = true)
proc initialiseAllResourceGroups*(this: ptr ResourceGroupManager)
{.pop.}
{.pop.}


{.push header: "OgreCamera.h".}
type
  Camera* {.importcpp: "Ogre::Camera", bycopy.} = object

{.push importcpp: "#.$1(@)".}
# TODO: @deprecated attach to SceneNode and use SceneNode::lookAt
proc setPosition*(this: ptr Camera, x: Real, y: Real, z: Real)
proc lookAt*(this: ptr Camera, x: Real, y: Real, z: Real)
{.pop.}
{.pop.}


{.push header: "OgreSceneManager.h".}
type
  SceneManager* {.importcpp: "Ogre::SceneManager", bycopy.} = object
  # /// Bitmask containing scene types
  #   typedef uint16 SceneTypeMask;
  # SceneType* = enum  # {.size: sizeof(cint).} = enum (probably uint16)
  #   ST_GENERIC = 1,
  #   ST_EXTERIOR_CLOSE = 2,
  #   ST_EXTERIOR_FAR = 4,
  #   ST_EXTERIOR_REAL_FAR = 8,
  #   ST_INTERIOR = 16,

{.push importcpp: "#.$1(@)".}
proc createCamera*(this: ptr SceneManager, name: cstring): ptr Camera
{.pop.}
{.pop.}


{.push header: "OgreRoot.h".}
type
  Root* {.importcpp: "Ogre::Root", bycopy.} = object

proc newRoot*(pluginFileName: cstring = pluginsConfig, configFileName: cstring = "ogre.cfg", logFileName: cstring = "ogre.log"): ptr Root {.importcpp: "new Ogre::Root(@)", constructor.}

{.push importcpp: "#.$1(@)".}
proc showConfigDialog(this: ptr Root, dialog: ptr ConfigDialog = nil): bool
proc restoreConfig*(this: ptr Root): bool
proc initialise*(this: ptr Root, autoCreateWindow: bool, windowTitle: cstring = "OGRE Render Window", customCapabilitiesConfig: cstring = ""): ptr RenderWindow
proc createRenderWindow*(this: ptr Root, name: cstring, width: uint, height: uint, fullScreen: bool, miscParams: ptr NameValuePairList = nil): ptr RenderWindow
proc createSceneManager*(this: ptr Root): ptr SceneManager
{.pop.}
{.pop.}


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

      # echo ">>>"
      # echo $nativeWindowHandle
      # echo nativeWindowHandle.toString().c_str()
      # echo ">>>"

      discard root.initialise(false)

      var misc: NameValuePairList
      misc[initString("externalWindowHandle")] = nativeWindowHandle.toString()

      var renderWindow = root.createRenderWindow("Main Render Window", 800, 600, false, misc.addr)

    test "Loading resources":
      var resourceManager: ptr ResourceGroupManager = getSingletonPtr()
      resourceManager.addResourceLocation(mediaDir / "packs" / "SdkTrays.zip", "Zip", resGroup="Essential")

      resourceManager.addResourceLocation(mediaDir, "FileSystem", resGroup="General")
      resourceManager.addResourceLocation(mediaDir / "models", "FileSystem", resGroup="General")
      resourceManager.addResourceLocation(mediaDir / "materials" / "scripts", "FileSystem", resGroup="General")
      resourceManager.addResourceLocation(mediaDir / "materials" / "textures", "FileSystem", resGroup="General")

      # Ogre::TextureManager::getSingleton().setDefaultNumMipmaps(5);

      resourceManager.initialiseAllResourceGroups()

    test "Scene creation":
      var
        sceneManager = root.createSceneManager()
        camera = sceneManager.createCamera("camera")

      camera.setPosition(0.0, 0.0, 80.0)
      camera.lookAt(0, 0, -300)
