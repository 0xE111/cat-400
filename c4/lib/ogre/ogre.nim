## Basic wrapper for Ogre3d.
## Only minimal requred definitions included.
when isMainModule:
  import unittest
  import sdl2/sdl, sdl2/sdl_syswm

when defined(windows):
  raise newException(LibraryError, "Not implemented")

elif defined(macosx):
  raise newException(LibraryError, "Not implemented")

elif defined(linux):
  {.link: "/usr/lib/libOgre.so".}
  {.link: "/usr/lib/libOgreMain.so".}
  {.link: "/usr/lib/libOgreBites.so".}
  {.passC: "-I/usr/include/OGRE -I/usr/include/OGRE/Bites".}  # -I/usr/include/OGRE/RTShaderSystem ".}

  const
    defaultPluginFile* = "/usr/share/OGRE/plugins.cfg"
    defaultMediaDir* = "/usr/share/OGRE/Media"

else:
  raise newException(LibraryError, "Platform not supported")  


type
  StdMap[K, V] {.header: "<map>", importcpp: "std::map".} = object
  String* {.header: "OgrePrerequisites.h", importcpp: "Ogre::String", bycopy.} = cstring  # object
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


# ---- Render operation ----
{.push header: "OgreRenderOperation.h".}
type
  OperationType* {.importcpp: "Ogre::RenderOperation::OperationType", bycopy.} = enum
    OT_POINT_LIST = 1, OT_LINE_LIST = 2, OT_LINE_STRIP = 3, OT_TRIANGLE_LIST = 4, 
    OT_TRIANGLE_STRIP = 5, OT_TRIANGLE_FAN = 6, OT_PATCH_1_CONTROL_POINT = 7, OT_PATCH_2_CONTROL_POINT = 8, 
    OT_PATCH_3_CONTROL_POINT = 9, OT_PATCH_4_CONTROL_POINT = 10, OT_PATCH_5_CONTROL_POINT = 11, OT_PATCH_6_CONTROL_POINT = 12, 
    OT_PATCH_7_CONTROL_POINT = 13, OT_PATCH_8_CONTROL_POINT = 14, OT_PATCH_9_CONTROL_POINT = 15, OT_PATCH_10_CONTROL_POINT = 16, 
    OT_PATCH_11_CONTROL_POINT = 17, OT_PATCH_12_CONTROL_POINT = 18, OT_PATCH_13_CONTROL_POINT = 19, OT_PATCH_14_CONTROL_POINT = 20, 
    OT_PATCH_15_CONTROL_POINT = 21, OT_PATCH_16_CONTROL_POINT = 22, OT_PATCH_17_CONTROL_POINT = 23, OT_PATCH_18_CONTROL_POINT = 24, 
    OT_PATCH_19_CONTROL_POINT = 25, OT_PATCH_20_CONTROL_POINT = 26, OT_PATCH_21_CONTROL_POINT = 27, OT_PATCH_22_CONTROL_POINT = 28, 
    OT_PATCH_23_CONTROL_POINT = 29, OT_PATCH_24_CONTROL_POINT = 30, OT_PATCH_25_CONTROL_POINT = 31, OT_PATCH_26_CONTROL_POINT = 32, 
    OT_PATCH_27_CONTROL_POINT = 33, OT_PATCH_28_CONTROL_POINT = 34, OT_PATCH_29_CONTROL_POINT = 35, OT_PATCH_30_CONTROL_POINT = 36, 
    OT_PATCH_31_CONTROL_POINT = 37, OT_PATCH_32_CONTROL_POINT = 38, 
    OT_DETAIL_ADJACENCY_BIT = 1 shl 6,
    OT_LINE_LIST_ADJ = OT_LINE_LIST.int or OT_DETAIL_ADJACENCY_BIT.int, 
    OT_LINE_STRIP_ADJ = OT_LINE_STRIP.int or OT_DETAIL_ADJACENCY_BIT.int,
    OT_TRIANGLE_LIST_ADJ = OT_TRIANGLE_LIST.int or OT_DETAIL_ADJACENCY_BIT.int,
    OT_TRIANGLE_STRIP_ADJ = OT_TRIANGLE_STRIP.int or OT_DETAIL_ADJACENCY_BIT.int 
{.pop.}


# ---- ResourceGroupManager ----
{.push header: "OgreResourceGroupManager.h".}
type
  ResourceGroupManager* {.importcpp: "Ogre::ResourceGroupManager", bycopy.} = object

var
  DEFAULT_RESOURCE_GROUP_NAME {.importcpp: "Ogre::ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME".}: String

proc getSingletonPtr*(): ptr ResourceGroupManager {.importcpp: "Ogre::ResourceGroupManager::getSingletonPtr()".}

{.push importcpp: "#.$1(@)".}
proc addResourceLocation*(this: ptr ResourceGroupManager, name: cstring, locType: cstring, resGroup: cstring = DEFAULT_RESOURCE_GROUP_NAME, recursive: bool = false, readOnly: bool = true)
proc initialiseAllResourceGroups*(this: ptr ResourceGroupManager)
{.pop.}
{.pop.}


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


# ---- Radian ----
{.push header: "OgreMath.h".}
type
  Radian* {.importcpp: "Ogre::Radian", bycopy.} = object

proc initRadian*(r: Real): Radian {.importcpp: "Ogre::Radian(@)", constructor.}
{.pop.}


# ---- Mesh ----
{.push header: "OgreMesh.h".}
type
  Mesh* {.importcpp: "Ogre::Mesh", bycopy.} = object
  MeshPtr* {.importcpp: "Ogre::MeshPtr", bycopy.} = object
{.pop.}


# ---- Vector3 ----
{.push header: "OgreVector.h".}
type
  Vector2* {.importcpp: "Ogre::Vector2", bycopy.} = object
    x*, y*: Real

  Vector3* {.importcpp: "Ogre::Vector3", bycopy.} = object
    x*, y*, z*: Real

  Vector4* {.importcpp: "Ogre::Vector4", bycopy.} = object
    x*, y*, z*, w*: Real

proc initVector2*(fX: Real, fY: Real): Vector2 {.importcpp: "Ogre::Vector2(@)", constructor.}
proc initVector3*(fX: Real, fY: Real, fZ: Real): Vector3 {.importcpp: "Ogre::Vector3(@)", constructor.}
proc initVector4*(fX: Real, fY: Real, fZ: Real, fW: Real): Vector4 {.importcpp: "Ogre::Vector4(@)", constructor.}
{.pop.}


# ---- MovableObject ----
{.push header: "OgreMovableObject.h".}
type
  MovableObject* {.importcpp: "Ogre::MovableObject", bycopy, inheritable.} = object
{.pop.}


# ---- ManualObject ----
{.push header: "OgreManualObject.h".}
type
  ManualObject* {.importcpp: "Ogre::ManualObject", bycopy.} = object of MovableObject
  ManualObjectSection* {.importcpp: "Ogre::ManualObject::ManualObjectSection", bycopy.} = object

proc initManualObject*(name: String): ManualObject {.importcpp: "Ogre::ManualObject(@)", constructor.}
{.push importcpp: "#.$1(@)".}
proc begin*(this: ManualObject, materialName: String, opType: OperationType = OT_TRIANGLE_LIST, groupName: String = DEFAULT_RESOURCE_GROUP_NAME)
proc position*(this: ManualObject, pos: Vector3)
proc position*(this: ManualObject, x: float, y: float, z: float)
proc normal*(this: ManualObject, norm: Vector3)
proc normal*(this: ManualObject, x: float, y: float, z: float)
proc textureCoord*(this: ManualObject, u: float)
proc textureCoord*(this: ManualObject, u: float, v: float)
proc textureCoord*(this: ManualObject, u: float, v: float, w: float)
proc textureCoord*(this: ManualObject, x: float, y: float, z: float, w: float)
proc textureCoord*(this: ManualObject, uv: Vector2)
proc textureCoord*(this: ManualObject, uvw: Vector3)
proc textureCoord*(this: ManualObject, xyzw: Vector4)
proc quad*(this: ManualObject, i1, i2, i3, i4: uint32)
proc `end`*(this: ManualObject): ptr ManualObjectSection
proc convertToMesh*(this: ManualObject, meshName: String, groupName: String = DEFAULT_RESOURCE_GROUP_NAME): MeshPtr
{.pop.}
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


# ---- Transform ----
type
  TransformSpace* {.importcpp: "Ogre::Node::TransformSpace", bycopy.} = enum
    TS_LOCAL, TS_PARENT, TS_WORLD


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

proc destroy*(this: ptr SceneNode) {.importcpp: "#.~SceneNode()".}

{.push importcpp: "#.$1(@)".}
# TODO: const Vector3& translate = Vector3::ZERO,
# const Quaternion& rotate = Quaternion::IDENTITY );
proc createChildSceneNode*(this: ptr SceneNode): ptr SceneNode
# TODO: ugly
proc attachObject*(this: ptr SceneNode, obj: ptr MovableObject)
proc attachObject*(this: ptr SceneNode, obj: ptr Entity)
proc attachObject*(this: ptr SceneNode, obj: ptr Camera)

proc getPosition*(this: ptr SceneNode): Vector3
proc setPosition*(this: ptr SceneNode, x: Real, y: Real, z: Real)

proc setDirection*(this: ptr SceneNode, x: Real, y: Real, z: Real)

proc roll*(this: ptr SceneNode, angle: Radian, relativeTo: TransformSpace = TS_LOCAL)
proc pitch*(this: ptr SceneNode, angle: Radian, relativeTo: TransformSpace = TS_LOCAL)
proc yaw*(this: ptr SceneNode, angle: Radian, relativeTo: TransformSpace = TS_LOCAL)
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

proc createManualObject*(this: ptr SceneManager): ptr ManualObject
proc createManualObject*(this: ptr SceneManager, name: cstring): ptr ManualObject
{.pop.}
{.pop.}


# ---- OgreWindowEventUtilities ----
{.push header: "OgreWindowEventUtilities.h".}
proc messagePump*() {.importcpp: "OgreBites::WindowEventUtilities::messagePump()".}
{.pop.}


# ---- Root ----
{.push header: "OgreRoot.h".}
type
  Root* {.importcpp: "Ogre::Root", bycopy.} = object

proc newRoot*(pluginFileName: cstring = defaultPluginFile, configFileName: cstring = "ogre.cfg", logFileName: cstring = "ogre.log"): ptr Root {.importcpp: "new Ogre::Root(@)", constructor.}

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
