import os
import logging
import strformat
import unittest

import sdl2/sdl, sdl2/sdl_syswm

import ../../lib/ogre/ogre
import ../../messages
import ../../threads
import ../../loop


type
  OgreVideoSystem* {.inheritable.} = object
    window*: Window
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

  OgreVideo* {.inheritable.} = object
    node*: ptr SceneNode


# ---- Component ----
method init*(self: ref OgreVideoSystem, video: ref OgreVideo) {.base.} =
  video.node = self.sceneManager.getRootSceneNode().createChildSceneNode()

method dispose*(self: ref OgreVideo) {.base.} =
  self.node.destroy()


# ---- System ----
method init*(self: ref OgreVideoSystem, title: string = "Game", x: int = 200, y: int = 400, width: int = 800, height: int = 600, fullscreen: bool = false) {.base.} =
  # ---- SDL ----
  logging.debug "Initializing SDL video system"

  try:
    if initSubSystem(INIT_VIDEO) != 0:
      raise newException(LibraryError, "Could not init SDL video subsystem")

    # var displayMode: DisplayMode
    # if getCurrentDisplayMode(0, displayMode.addr) != 0:
    #   raise newException(LibraryError, "Could not get current display mode: " & $getError())

    self.window = createWindow(title, x, y, width, height, (WINDOW_SHOWN or WINDOW_RESIZABLE or (if fullscreen: WINDOW_FULLSCREEN_DESKTOP else: 0)).uint32)
    if self.window == nil:
      raise newException(LibraryError, "Could not create SDL window")

    if setRelativeMouseMode(true) != 0:
      raise newException(LibraryError, "Could not enable relative mouse mode")

  except LibraryError:
    logging.fatal getCurrentExceptionMsg() & ": " & $getError()
    quitSubSystem(INIT_VIDEO)
    raise

  logging.debug "SDL video system initialized"

  # ---- Ogre ----
  logging.debug "Initializing OGRE"

  self.root = newRoot(logFileName=joinPath(getAppDir(), "ogre.log"))
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
  version(info.version)
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


method update*(self: ref OgreVideoSystem, dt: float) {.base.} =
  # if logLevel <= lvlDebug:
  #   show stats?

  # messagePump()
  discard self.root.renderOneFrame(dt)
  # self.window.glSwapWindow()


method dispose*(self: ref OgreVideoSystem) {.base.} =
  # TODO: shutdown
  quitSubSystem(INIT_VIDEO)
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
method process*(self: ref OgreVideoSystem, message: ref Message) {.base.} =
  logging.warn &"No rule for processing {message}"

# method process*(self: ref OgreVideoSystem, message: ref WindowResizeMessage) =

#   self.updateViewport(message.width, message.height)

method run*(self: ref OgreVideoSystem) {.base.} =
  loop(frequency=30) do:
    while true:
      let message = tryRecv()
      if message.isNil:
        break
      self.process(message)
  do:
    self.update(dt)


when isMainModule:
  suite "System tests":
    test "Running inside thread":
      spawn("thread") do:
        var system = OgreVideoSystem()
        system.init()
        system.run()
        system.dispose()

      sleep 1000
