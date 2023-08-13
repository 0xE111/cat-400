import ../../logging
import ../../systems/video/sdl as c4sdl
import ../../lib/ogre/ogre
import ../../messages

import sdl2


type
  VideoSystem* = object of c4sdl.VideoSystem
    root*: ptr Root
    resourceGroupManager*: ptr ResourceGroupManager
    sceneManager*: ptr SceneManager

    renderWindow*: ptr RenderWindow
    camera*: ptr Camera
    viewport*: ptr Viewport

  Video* = object of RootObj
    node*: ptr SceneNode

  VideoInitMessage* = object of c4sdl.VideoInitMessage

  OgreException* = object of CatchableError


register VideoInitMessage


method process*(self: ref VideoSystem, message: ref VideoInitMessage) =
  withLog(DEBUG, "initializing video"):
    if initSubSystem(INIT_VIDEO) != 0: handleError("failed to initialize video")

  withLog(DEBUG, "creating window"):
    self.window = createWindow(
      title=message.windowTitle.cstring,
      x=message.windowX,
      y=message.windowY,
      w=message.windowWidth,
      h=message.windowHeight,
      flags=message.flags,
    )
    if self.window.isNil: handleError("failed to create window")

  var info: WMinfo
  info.version.getVersion()
  if self.window.getWMInfo(info) == False32: handleError("Failed to get window info")

  # https://github.com/Vladar4/sdl2_nim/blob/master/sdl2/sdl_syswm.nim
  var nativeWindowHandle =
    case info.subsystem:
      of SysWM_X11:
        type
          SysWMinfoX11Obj = object
            display: pointer
            window: culong
        cast[ptr SysWMinfoX11Obj](info.padding.addr)[].window

      else:
        raise newException(LibraryError, "SDL video subsystem unsupported")

  # when defined(windows):
  #   var nativeWindowHandle = info.info.win.window
  # elif defined(linux):
  #   var nativeWindowHandle = info.info.x11.window  # culong
  # elif defined(macosx):
  #   var nativeWindowHandle = info.info.cocoa.window
  # else:
  #   raise newException(LibraryError, "SDL video driver undefined")

  withLog(DEBUG, "initializing Ogre3D"):
    self.root = newRoot(logFileName="")

  if not self.root.restoreConfig() and not self.root.showConfigDialog():
    raise newException(OgreException, "Could not make Ogre3D config")

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
    self.resourceGroupManager = getResourceGroupManager()

  withLog(DEBUG, "creating scene manager"):
    self.sceneManager = self.root.createSceneManager()

  withLog(DEBUG, "creating camera"):
    self.camera = self.sceneManager.createCamera("camera")
    self.camera.setAspectRatio(Real(message.windowWidth / message.windowHeight))

  withLog(DEBUG, "creating viewport"):
    self.viewport = self.renderWindow.addViewport(self.camera)
    self.viewport.setBackgroundColour(initColourValue(0, 0, 0))


method update*(self: ref VideoSystem, dt: float) =
  withLog(TRACE, "updating ogre"):
    discard self.root.renderOneFrame(dt)
