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
  {.link: "/usr/lib/libOgreBites.so".}
  {.passC: "-I/usr/include/OGRE -I/usr/include/OGRE/Bites".}  # -I/usr/include/OGRE/RTShaderSystem ".}

  const
    pluginsConfig* = "/usr/share/OGRE/plugins.cfg"
    mediaDir* = "/usr/share/OGRE/Media"


type
  StdMap[K, V] {.header: "<map>", importcpp: "std::map".} = object
  String* {.header: "OgrePrerequisites.h", importcpp: "Ogre::String", bycopy.} = object
  # String* {.header: "<string>", importcpp: "std::string", bycopy.} = object
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


# ---- Colour ----
{.push header: "OgreColourValue.h".}
type
  ColourValue* {.importcpp: "Ogre::ColourValue", bycopy.} = object

proc initColourValue*(red: cfloat = 1.0, green: cfloat = 1.0, blue: cfloat = 1.0, alpha: cfloat = 1.0): ColourValue {.importcpp: "Ogre::ColourValue(@)", constructor.}
{.pop.}


# ---- Quaternion ----
{.push header: "OgreQuaternion.h".}
type
  Quaternion* {.importcpp: "Ogre::Quaternion", bycopy.} = object

proc initQuaternion*(fW: Real, fX: Real, fY: Real, fZ: Real): Quaternion {.importcpp: "Ogre::Quaternion(@)", constructor.}
{.pop.}


# ---- MovableObject ----
{.push header: "OgreMovableObject.h".}
type
  MovableObject* {.importcpp: "Ogre::MovableObject", bycopy, inheritable.} = object
{.pop.}


# ---- Entity ----
{.push header: "OgreEntity.h".}
type
  Entity* {.importcpp: "Ogre::Entity", bycopy.} = object of MovableObject
{.pop.}


# ---- Light ----
{.push header: "OgreLight.h".}
type
  Light* {.importcpp: "Ogre::Light", bycopy.} = object of MovableObject

{.push importcpp: "#.$1(@)".}
# TODO @deprecated attach to SceneNode and use SceneNode::setPosition
proc setPosition*(this: ptr Light, x: Real, y: Real, z: Real)
{.pop.}
{.pop.}


# ---- Camera ----
{.push header: "OgreCamera.h".}
type
  Camera* {.importcpp: "Ogre::Camera", bycopy.} = object

{.push importcpp: "#.$1(@)".}
# TODO: @deprecated attach to SceneNode and use SceneNode::lookAt
proc setPosition*(this: ptr Camera, x: Real, y: Real, z: Real)
proc lookAt*(this: ptr Camera, x: Real, y: Real, z: Real)
proc setAspectRatio*(this: ptr Camera, ratio: Real)
{.pop.}
{.pop.}


# ---- Node ----
{.push header: "OgreSceneNode.h".}
type
  Node* {.importcpp: "Ogre::Node", bycopy, inheritable.} = object

{.push importcpp: "#.$1(@)".}
proc setOrientation*(this: ptr Node, q: ptr Quaternion)
proc setOrientation*(this: ptr Node, w: Real, x: Real, y: Real, z: Real)
{.pop.}
{.pop.}


# ---- SceneNode ----
{.push header: "OgreSceneNode.h".}
type
  SceneNode* {.importcpp: "Ogre::SceneNode", bycopy.} = object of Node

{.push importcpp: "#.$1(@)".}
# TODO: const Vector3& translate = Vector3::ZERO,
# const Quaternion& rotate = Quaternion::IDENTITY );
proc createChildSceneNode*(this: ptr SceneNode): ptr SceneNode
# TODO: ugly
proc attachObject*(this: ptr SceneNode, obj: ptr MovableObject)
proc attachObject*(this: ptr SceneNode, obj: ptr Entity)
proc attachObject*(this: ptr SceneNode, obj: ptr Camera)

proc setPosition*(this: ptr SceneNode, x: Real, y: Real, z: Real)
proc setDirection*(this: ptr SceneNode, x: Real, y: Real, z: Real)
{.pop.}
{.pop.}


# ---- Viewport ----
{.push header: "OgreViewport.h".}
type
  Viewport* {.importcpp: "Ogre::Viewport", bycopy.} = object

{.push importcpp: "#.$1(@)".}
proc setBackgroundColour*(this: ptr Viewport, colour: ColourValue)
{.pop.}
{.pop.}


# ---- RenderWindow ----
{.push header: "OgreRenderWindow.h".}
type
  RenderWindow* {.importcpp: "Ogre::RenderWindow", bycopy.} = object

{.push importcpp: "#.$1(@)".}
# proc newRenderWindow*(): ptr RenderWindow {.header: "OgreRenderWindow.h", importcpp: "new(Ogre::RenderWindow)", constructor.}
proc addViewport*(this: ptr RenderWindow, cam: ptr Camera, ZOrder: cint = 0, left: cfloat = 0.0, top: cfloat = 0.0, width: cfloat = 1.0, height: cfloat = 1.0): ptr Viewport
{.pop.}
{.pop.}


# ---- ResourceGroupManager ----
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


# ---- SceneManager ----
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
proc createEntity*(this: ptr SceneManager, meshName: cstring): ptr Entity
proc getRootSceneNode*(this: ptr SceneManager): ptr SceneNode
proc setAmbientLight*(this: ptr SceneManager, colour: ColourValue)
proc createLight*(this: ptr SceneManager, name: cstring): ptr Light
{.pop.}
{.pop.}


# ---- OgreWindowEventUtilities ----
{.push header: "OgreWindowEventUtilities.h".}
proc messagePump() {.importcpp: "OgreBites::WindowEventUtilities::messagePump()".}
{.pop.}


# ---- Root ----
{.push header: "OgreRoot.h".}
type
  Root* {.importcpp: "Ogre::Root", bycopy.} = object

proc newRoot*(pluginFileName: cstring = pluginsConfig, configFileName: cstring = "ogre.cfg", logFileName: cstring = "ogre.log"): ptr Root {.importcpp: "new Ogre::Root(@)", constructor.}

{.push importcpp: "#.$1(@)".}
proc showConfigDialog*(this: ptr Root, dialog: ptr ConfigDialog = nil): bool
proc restoreConfig*(this: ptr Root): bool
proc initialise*(this: ptr Root, autoCreateWindow: bool, windowTitle: cstring = "OGRE Render Window", customCapabilitiesConfig: cstring = ""): ptr RenderWindow
proc createRenderWindow*(this: ptr Root, name: cstring, width: uint, height: uint, fullScreen: bool, miscParams: ptr NameValuePairList = nil): ptr RenderWindow
proc createSceneManager*(this: ptr Root): ptr SceneManager
proc renderOneFrame*(this: ptr Root): bool
proc renderOneFrame*(this: ptr Root, timeSinceLastFrame: Real): bool
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

    test "SDL+Ogre3d":
      # ---- SDL initialization ----
      if sdl.initSubSystem(sdl.INIT_VIDEO) != 0:
        raise newException(LibraryError, "Could not init SDL video subsystem")

      var window = sdl.createWindow(
        "Ogre3d test", 100, 100, 800, 600,
        (sdl.WINDOW_SHOWN or sdl.WINDOW_RESIZABLE).uint32,  # seems like WINDOW_OPENGL is not necessary
      )
      if window == nil:
        raise newException(LibraryError, "Could not create SDL window")

      if sdl.setRelativeMouseMode(true) != 0:
        raise newException(LibraryError, "Could not enable relative mouse mode")

      # ---- Getting native window handle ----
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

      # ---- Initializing OGRE ----
      discard root.initialise(false)

      var misc: NameValuePairList
      misc[initString("externalWindowHandle")] = nativeWindowHandle.toString()

      var renderWindow = root.createRenderWindow("Main Render Window", 800, 600, false, misc.addr)

      # ---- Loading resources ----
      var resourceManager: ptr ResourceGroupManager = getSingletonPtr()
      resourceManager.addResourceLocation(mediaDir / "packs" / "SdkTrays.zip", "Zip", resGroup="Essential")

      resourceManager.addResourceLocation(mediaDir, "FileSystem", resGroup="General")
      resourceManager.addResourceLocation(mediaDir / "models", "FileSystem", resGroup="General")
      resourceManager.addResourceLocation(mediaDir / "materials" / "scripts", "FileSystem", resGroup="General")
      resourceManager.addResourceLocation(mediaDir / "materials" / "textures", "FileSystem", resGroup="General")

      # Ogre::TextureManager::getSingleton().setDefaultNumMipmaps(5);

      resourceManager.initialiseAllResourceGroups()

      # ---- Creating scene ----
      var sceneManager = root.createSceneManager()

      var camera = sceneManager.createCamera("camera")
      camera.setPosition(0.0, 0.0, 150.0)
      camera.lookAt(0, 0, -300)

      # ---- Creating a viewport ----
      var viewport = renderWindow.addViewport(camera)
      viewport.setBackgroundColour(initColourValue(0, 0, 0))
      camera.setAspectRatio(Real(800/600))

      # ---- Setting up the scene ----
      var entity = sceneManager.createEntity("ogrehead.mesh")
      var node = sceneManager.getRootSceneNode().createChildSceneNode()
      node.attachObject(entity)

      sceneManager.setAmbientLight(initColourValue(0.5, 0.5, 0.5))

      var light = sceneManager.createLight("MainLight");
      light.setPosition(20.0, 80.0, 50.0);

      while true:
        messagePump()
        discard root.renderOneFrame()
