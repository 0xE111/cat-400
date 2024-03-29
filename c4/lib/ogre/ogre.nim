## Basic wrapper for Ogre3d.
## Only minimal requred definitions included.

type
  StdMap[K, V] {.header: "<map>", importcpp: "std::map".} = object
  # String* {.header: "OgrePrerequisites.h", importcpp: "Ogre::String", bycopy.} = object
  String* {.header: "<string>", importcpp: "std::string", bycopy.} = cstring
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

proc getResourceGroupManager*(): ptr ResourceGroupManager {.importcpp: "Ogre::ResourceGroupManager::getSingletonPtr()".}

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

let NEGATIVE_UNIT_Z* {.importcpp: "Ogre::Vector3::NEGATIVE_UNIT_Z".}: Vector3

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
proc begin*(this: ptr ManualObject, materialName: String, opType: OperationType = OT_TRIANGLE_LIST, groupName: String = DEFAULT_RESOURCE_GROUP_NAME)
# proc position*(this: ptr ManualObject, pos: Vector3)
proc position*(this: ptr ManualObject, x: float, y: float, z: float)
proc normal*(this: ptr ManualObject, norm: Vector3)
proc normal*(this: ptr ManualObject, x: float, y: float, z: float)
proc colour*(this: ptr ManualObject, col: ColourValue)
proc colour*(this: ptr ManualObject, r: Real, g: Real, b: Real, a: Real = 1.0)
proc textureCoord*(this: ptr ManualObject, u: float)
proc textureCoord*(this: ptr ManualObject, u: float, v: float)
proc textureCoord*(this: ptr ManualObject, u: float, v: float, w: float)
proc textureCoord*(this: ptr ManualObject, x: float, y: float, z: float, w: float)
proc textureCoord*(this: ptr ManualObject, uv: Vector2)
proc textureCoord*(this: ptr ManualObject, uvw: Vector3)
proc textureCoord*(this: ptr ManualObject, xyzw: Vector4)
proc triangle*(this: ptr ManualObject, i1, i2, i3: uint32)
proc quad*(this: ptr ManualObject, i1, i2, i3, i4: uint32)
proc `end`*(this: ptr ManualObject): ptr ManualObjectSection
proc convertToMesh*(this: ptr ManualObject, meshName: String, groupName: String = DEFAULT_RESOURCE_GROUP_NAME): MeshPtr
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
{.pop.}


# ---- Camera ----
{.push header: "OgreCamera.h".}
type
  Camera* {.importcpp: "Ogre::Camera", bycopy.} = object

{.push importcpp: "#.$1(@)".}
proc setAspectRatio*(this: ptr Camera, ratio: Real)
proc setNearClipDistance*(this: ptr Camera, nearDist: Real)
proc setFarClipDistance*(this: ptr Camera, farDist: Real)
{.pop.}
{.pop.}


# ---- Transform ----
type
  TransformSpace* {.importcpp: "Ogre::Node::TransformSpace", bycopy.} = enum
    TS_LOCAL, TS_PARENT, TS_WORLD


# ---- Node ----
{.push header: "OgreNode.h".}
type
  Node* {.importcpp: "Ogre::Node", bycopy, inheritable.} = object

{.push importcpp: "#.$1(@)".}
proc setOrientation*(this: ptr Node, q: ptr Quaternion)
proc setOrientation*(this: ptr Node, w: Real, x: Real, y: Real, z: Real)
proc setPosition*(this: ptr, x, y, z: Real)
proc setPosition*(this: ptr, pos: Vector3)
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

proc lookAt*(this: ptr SceneNode, targetPoint: Vector3, relativeTo: TransformSpace, localDirectionVector: Vector3 = NEGATIVE_UNIT_Z)
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

proc newRoot*(pluginFileName: cstring = "plugins.cfg", configFileName: cstring = "ogre.cfg", logFileName: cstring = "ogre.log"): ptr Root {.importcpp: "new Ogre::Root(@)", constructor.}

{.push importcpp: "#.$1(@)".}
proc showConfigDialog*(this: ptr Root, dialog: ptr ConfigDialog = nil): bool
proc restoreConfig*(this: ptr Root): bool
proc initialise*(this: ptr Root, autoCreateWindow: bool, windowTitle: cstring = "OGRE Render Window"): ptr RenderWindow
proc createRenderWindow*(this: ptr Root, name: cstring, width: uint, height: uint, fullScreen: bool, miscParams: ptr NameValuePairList = nil): ptr RenderWindow
proc createSceneManager*(this: ptr Root): ptr SceneManager
proc renderOneFrame*(this: ptr Root): bool
proc renderOneFrame*(this: ptr Root, timeSinceLastFrame: Real): bool
{.pop.}
{.pop.}
