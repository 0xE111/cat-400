import c4/logging
import c4/systems/video/sdl as c4sdl
import c4/lib/ogre/ogre
import c4/messages

import sdl2/sdl, sdl2/sdl_syswm


type
  OgreVideoSystem* = object of SdlVideoSystem
    root*: ptr Root
    resourceManager*: ptr ResourceGroupManager
    sceneManager*: ptr SceneManager

    renderWindow*: ptr RenderWindow
    camera*: ptr Camera
    viewport*: ptr Viewport

  OgreVideo* = object of RootObj
    node*: ptr SceneNode

  OgreVideoInitMessage* = object of SdlVideoInitMessage

  OgreException* = object of CatchableError


register OgreVideoInitMessage


method process*(self: ref OgreVideoSystem, message: ref OgreVideoInitMessage) =
  withLog(DEBUG, "initializing video"):
    if sdl.initSubSystem(sdl.INIT_VIDEO) != 0: handleError("failed to initialize video")

  withLog(DEBUG, "creating window"):
    self.window = sdl.createWindow(
      message.windowTitle.cstring,
      message.windowX,
      message.windowY,
      message.windowWidth,
      message.windowHeight,
      message.flags,
    )
    if self.window.isNil: handleError("failed to create window")

  withLog(DEBUG, "initializing Ogre3D"):
    self.root = newRoot(logFileName="")

  if not self.root.restoreConfig() and not self.root.showConfigDialog():
    raise newException(OgreException, "Could not make Ogre3D config")

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

  withLog(DEBUG, "initializing root node"):
    discard self.root.initialise(false)

  var params: NameValuePairList
  params[initString("externalWindowHandle")] = nativeWindowHandle.toString()

  withLog(DEBUG, "creating render window"):
    self.renderWindow = self.root.createRenderWindow(
      message.windowTitle.cstring,
      message.windowWidth.uint,
      message.windowHeight.uint,
      false,
      params.addr,
    )

  withLog(DEBUG, "loading resource manager"):
    self.resourceManager = getSingletonPtr()

  withLog(DEBUG, "creating scene manager"):
    self.sceneManager = self.root.createSceneManager()

  withLog(DEBUG, "creating camera"):
    self.camera = self.sceneManager.createCamera("camera")
    self.camera.setAspectRatio(Real(message.windowWidth / message.windowHeight))

  withLog(DEBUG, "creating viewport"):
    self.viewport = self.renderWindow.addViewport(self.camera)
    self.viewport.setBackgroundColour(initColourValue(0, 0, 0))

  debug "initialized ogre"

method update*(self: ref OgreVideoSystem, dt: float) =
  withLog(TRACE, "updating ogre"):
    discard self.root.renderOneFrame(dt)
