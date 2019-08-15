import logging
import strformat
import os
import sequtils
import tables

import sdl2/sdl, sdl2/sdl_syswm

import ../../lib/ogre/ogre

import ../../messages
import ../../systems
import ../input/sdl as sdl_input
import ../../utils/stringify


type
  Window* = tuple[
    x, y, width, height: int,
    fullscreen: bool,
  ]

  VideoSystem* = object of System
    window*: sdl.Window
    windowConfig*: tuple[
      title: string,
      x, y: int,
      width, height: int,
      fullscreen: bool,
    ]

    root*: ptr ogre.Root
    resourceManager*: ptr ResourceGroupManager
    sceneManager*: ptr SceneManager

    renderWindow*: ptr RenderWindow
    camera*: ptr Camera
    viewport*: ptr Viewport

  Video* = object {.inheritable.}
    node*: ptr SceneNode


# ---- Component ----
method attach*(self: ref Video) {.base.} =
  assert systems.get("video") of ref VideoSystem

  let videoSystem = systems.get("video").as(ref VideoSystem)
  self.node = videoSystem.sceneManager.getRootSceneNode().createChildSceneNode()

method detach*(self: ref Video) {.base.} =
  self.node.destroy()


# ---- System ----
strMethod(VideoSystem, fields=false)


method init*(self: ref VideoSystem) =
  # ---- SDL ----
  logging.debug "Initializing SDL video system"

  # initialization
  self.windowConfig = (
    title: "Cat 400",
    x: 200,
    y: 400,
    width: 800,
    height: 600,
    fullscreen: false,
  )

  try:
    if sdl.initSubSystem(sdl.INIT_VIDEO) != 0:
      raise newException(LibraryError, "Could not init SDL video subsystem")

    # var displayMode: sdl.DisplayMode
    # if sdl.getCurrentDisplayMode(0, displayMode.addr) != 0:
    #   raise newException(LibraryError, "Could not get current display mode: " & $sdl.getError())

    self.window = sdl.createWindow(
      self.windowConfig.title,
      self.windowConfig.x,
      self.windowConfig.y,
      self.windowConfig.width,
      self.windowConfig.height,
      (sdl.WINDOW_SHOWN or sdl.WINDOW_RESIZABLE or (if self.windowConfig.fullscreen: sdl.WINDOW_FULLSCREEN_DESKTOP else: 0)).uint32,
    )
    if self.window == nil:
      raise newException(LibraryError, "Could not create SDL window")

    if sdl.setRelativeMouseMode(true) != 0:
      raise newException(LibraryError, "Could not enable relative mouse mode")

  except LibraryError:
    logging.fatal getCurrentExceptionMsg() & ": " & $sdl.getError()
    sdl.quitSubSystem(sdl.INIT_VIDEO)
    raise

  logging.debug "SDL video system initialized"

  # ---- Ogre ----
  logging.debug "Initializing OGRE"

  self.root = newRoot(logFileName=joinPath(getAppDir(), "ogre.log"))
  # TODO:
  # proc getAvailableRenderers*(this: ptr Root):
  # Once you have a pointer to the RenderSystem, you can use RenderSystem::getConfigOptions to see what options it provides.
  # RenderSystem* rs = mRoot->getRenderSystemByName("Direct3D9 Rendering Subsystem");

  # mRoot->setRenderSystem(rs);
  # rs->setConfigOption("Full Screen", "No");
  # rs->setConfigOption("Video Mode", "800 x 600 @ 32-bit colour");

  if not self.root.restoreConfig() and not self.root.showConfigDialog():
    raise newException(LibraryError, "Could not load config")

  # ---- Getting native window handle ----
  var info: sdl_syswm.SysWMinfo
  sdl.version(info.version)
  assert sdl_syswm.getWindowWMInfo(self.window, info.addr)

  when defined(windows):
    var nativeWindowHandle = info.info.win.window

  elif defined(linux):
    var nativeWindowHandle = info.info.x11.window  # culong

  elif defined(macosx):
    var nativeWindowHandle = info.info.cocoa.window

  else:
    raise newException(LibraryError, "SDL video driver undefined")

  # echo $nativeWindowHandle

  # ---- Initializing OGRE ----
  discard self.root.initialise(false)

  var params: NameValuePairList
  params[initString("externalWindowHandle")] = nativeWindowHandle.toString()

  self.renderWindow = self.root.createRenderWindow("Main Render Window", self.windowConfig.width.uint, self.windowConfig.height.uint, false, params.addr)

  # ---- Loading resources ----
  self.resourceManager = getSingletonPtr()

  # ---- Creating scene ----
  self.sceneManager = self.root.createSceneManager()

  # ---- Camera ----
  self.camera = self.sceneManager.createCamera("camera")
  self.camera.setAspectRatio(Real(self.windowConfig.width / self.windowConfig.height))

  # ---- Viewport ----
  self.viewport = self.renderWindow.addViewport(self.camera)
  self.viewport.setBackgroundColour(initColourValue(0, 0, 0))

  logging.debug "Ogre initialized"

  procCall self.as(ref System).init()

method update*(self: ref VideoSystem, dt: float) =
  procCall self.as(ref System).update(dt)

  # if logLevel <= lvlDebug:
  #   show stats?

  # messagePump()
  discard self.root.renderOneFrame(dt)
  # self.window.glSwapWindow()

proc `=destroy`*(self: var VideoSystem) =
  # TODO: shutdown
  sdl.quitSubSystem(sdl.INIT_VIDEO)
  logging.debug "Video system unloaded"

# ---- component ----
# method transform*(
#   self: var Video,
#   translation: tuple[x, y, z: float] = (0.0, 0.0, 0.0),
#   rotation: tuple[x, y, z: float] = (0.0, 0.0, 0.0),
#   scale: tuple[x, y, z: float] = (1.0, 1.0, 1.0)
# ) {.base.} =
#   self.node.setNodeTransform(
#     translation.x, translation.y, translation.z,
#     rotation.x, rotation.y, rotation.z,
#     scale.x, scale.y, scale.z,
#   )


# ---- handlers ----
# method process*(self: ref VideoSystem, message: ref WindowResizeMessage) =

#   self.updateViewport(message.width, message.height)
