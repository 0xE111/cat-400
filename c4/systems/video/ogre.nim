import logging
import strformat
import os
import ospaths
import sequtils

import sdl2/sdl, sdl2/sdl_syswm

import ../../lib/ogre/ogre

import ../../core/messages
import ../../systems
import ../../config
import ../input/sdl as sdl_input
import ../../utils/stringify


type
  Window* = tuple[
    x, y, width, height: int,
    fullscreen: bool,
  ]

  VideoSystem* = object of System
    window*: sdl.Window

    root*: ptr ogre.Root
    resourceManager*: ptr ResourceGroupManager
    sceneManager*: ptr SceneManager

    renderWindow*: ptr RenderWindow
    camera*: ptr Camera
    viewport*: ptr Viewport

  Video* = object {.inheritable.}
    node*: ptr SceneNode


# ---- Component ----
method init*(self: ref Video) {.base.} =
  raise newException(LibraryError, "Not implemented")

method dispose*(self: ref Video) {.base.} =
  raise newException(LibraryError, "Not implemented")


# ---- System ----
strMethod(VideoSystem, fields=false)


method init*(self: ref VideoSystem) =
  # ---- SDL ----
  logging.debug "Initializing SDL video system"

  let window = config.settings.video.window  # just an alias

  try:
    if sdl.initSubSystem(sdl.INIT_VIDEO) != 0:
      raise newException(LibraryError, "Could not init SDL video subsystem")

    # var displayMode: sdl.DisplayMode
    # if sdl.getCurrentDisplayMode(0, displayMode.addr) != 0:
    #   raise newException(LibraryError, "Could not get current display mode: " & $sdl.getError())

    self.window = sdl.createWindow(
      &"{config.title} v{config.version}",
      window.x,
      window.y,
      window.width,
      window.height,
      (sdl.WINDOW_SHOWN or sdl.WINDOW_RESIZABLE or (if window.fullscreen: sdl.WINDOW_FULLSCREEN_DESKTOP else: 0)).uint32,
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

  self.root = newRoot()
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

  when defined(SDL_VIDEO_DRIVER_WINDOWS):
    var nativeWindowHandle = info.info.win.window

  elif defined(SDL_VIDEO_DRIVER_X11):
    var nativeWindowHandle = info.info.x11.window  # culong

  elif defined(SDL_VIDEO_DRIVER_COCOA):
    var nativeWindowHandle = info.info.cocoa.window

  else:
    raise newException(LibraryError, "SDL video driver undefined")

  # echo $nativeWindowHandle

  # ---- Initializing OGRE ----
  discard self.root.initialise(false)

  var params: NameValuePairList
  params[initString("externalWindowHandle")] = nativeWindowHandle.toString()

  self.renderWindow = self.root.createRenderWindow("Main Render Window", window.width.uint, window.height.uint, false, params.addr)

  # ---- Loading resources ----
  self.resourceManager = getSingletonPtr()
  self.resourceManager.addResourceLocation(mediaDir / "packs" / "SdkTrays.zip", "Zip", resGroup="Essential")

  self.resourceManager.addResourceLocation(mediaDir, "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(mediaDir / "models", "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(mediaDir / "materials" / "scripts", "FileSystem", resGroup="General")
  self.resourceManager.addResourceLocation(mediaDir / "materials" / "textures", "FileSystem", resGroup="General")

  # Ogre::TextureManager::getSingleton().setDefaultNumMipmaps(5);

  self.resourceManager.initialiseAllResourceGroups()

  # ---- Creating scene ----
  self.sceneManager = self.root.createSceneManager()

  self.camera = self.sceneManager.createCamera("camera")

  # ---- Creating a viewport ----
  self.viewport = self.renderWindow.addViewport(self.camera)
  self.viewport.setBackgroundColour(initColourValue(0, 0, 0))
  self.camera.setAspectRatio(Real(window.width/window.height))

  logging.debug "Ogre initialized"

  procCall self.as(ref System).init()

method update*(self: ref VideoSystem, dt: float) =
  procCall self.as(ref System).update(dt)

  # if config.logLevel <= lvlDebug:
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
