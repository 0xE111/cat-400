import sdl2.sdl
import "../wrappers/horde3d/horde3d"

from logging import debug, fatal
from strformat import `&`
from os import getAppDir
from ospaths import `/`
from "../core/messages" import Message, subscribe, `$`


type
  Window* = tuple[
    x, y, width, height: int,
    fullscreen: bool,
  ]

  VideoSystem* = object {.inheritable.}
    window: sdl.Window
    pipeline: horde3d.Res
    camera: horde3d.Node


var
  # DEMO!!!
  model: horde3d.Node  
  angle: int


const
  forwardPipeline = staticRead("../wrappers/horde3d/assets/pipelines/forward.pipeline.xml")

let
  assetsDir = getAppDir() / "assets/video"


method onMessage*(self: ref VideoSystem, message: ref Message) {.base.} =
  logging.debug(&"Video got new message: {message}")

method init*(
  self: ref VideoSystem,
  title: string,
  window: Window,
) {.base.} =
  # ---- SDL ----
  logging.debug("Initializing SDL video system")

  try:
    if sdl.initSubSystem(sdl.INIT_VIDEO) != 0:
      raise newException(LibraryError, "Could not init SDL video subsystem" & $sdl.getError())

    # var displayMode: sdl.DisplayMode
    # if sdl.getCurrentDisplayMode(0, displayMode.addr) != 0:
    #   raise newException(LibraryError, "Could not get current display mode: " & $sdl.getError())
  
    self.window = sdl.createWindow(
      title,
      window.x.cint,
      window.y.cint,
      window.width.cint,
      window.height.cint,
      (sdl.WINDOW_SHOWN or sdl.WINDOW_OPENGL or sdl.WINDOW_RESIZABLE or (if window.fullscreen: sdl.WINDOW_FULLSCREEN_DESKTOP else: 0)).uint32,
    )
    if self.window == nil:
      raise newException(LibraryError, "Could not create SDL window: " & $sdl.getError())

    if sdl.glCreateContext(self.window) == nil:
      raise newException(LibraryError, "Could not create SDL OpenGL context: " & $sdl.getError())

  except LibraryError:
    sdl.quitSubSystem(sdl.INIT_VIDEO)
    logging.fatal(getCurrentExceptionMsg())
    raise
    
  logging.debug("SDL video system initialized")

  # ---- Horde3d ----
  logging.debug("Initializing " & $horde3d.GetVersionString())

  try:
    if not horde3d.Init(horde3d.RenderDevice.OpenGL4):
      raise newException(LibraryError, "Could not init Horde3D: " & $horde3d.GetError())
  
    # load default resources
    self.pipeline = horde3d.AddResource(horde3d.ResTypes.Pipeline, "pipelines/forward.pipeline.xml", 0.cint)
    if not self.pipeline.LoadResource(forwardPipeline, forwardPipeline.len + 1):
      raise newException(LibraryError, "Could not load Horde3D resources")

    # DEMO!!!
    var modelRes = AddResource(ResTypes.SceneGraph, "models/cube/cube.scene.xml", 0.cint)
    # discard modelRes.LoadResource(model, model.len + 1)
    logging.debug("Searching for assets in " & assetsDir)
    if not utLoadResourcesFromDisk(assetsDir):
      raise newException(LibraryError, "Could not load resources")
    model = RootNode.AddNodes(modelRes)
    angle = 0

    var light = RootNode.AddLightNode("light", 0.cint, "LIGHTING", "SHADOWMAP")
    light.SetNodeTransform(0.cfloat, 20.cfloat, 0.cfloat, 0.cfloat, 0.cfloat, 0.cfloat, 1.cfloat, 1.cfloat, 1.cfloat)
    light.SetNodeParamF(Light.RadiusF, 0.cint, 100.cfloat)

    # setting up camera
    self.camera = horde3d.RootNode.AddCameraNode("camera", self.pipeline)
    self.camera.SetNodeParamI(horde3d.Camera.ViewportXI, 0.cint)
    self.camera.SetNodeParamI(horde3d.Camera.ViewportYI, 0.cint)
    self.camera.SetNodeParamI(horde3d.Camera.ViewportWidthI, 400.cint)
    self.camera.SetNodeParamI(horde3d.Camera.ViewportHeightI, 300.cint)
    self.camera.SetupCameraView(45.cfloat, (400/300).cfloat, (0.5).cfloat, 2048.cfloat)

    self.pipeline.ResizePipelineBuffers(400.cint, 300.cint)

  except LibraryError:
    horde3d.Release()
    logging.fatal(getCurrentExceptionMsg())
    raise

  logging.debug("Horde3d initialized")

  messages.subscribe(proc (message: ref Message) = self.onMessage(message))

method update*(self: ref VideoSystem, dt: float) {.base.} =
  # DEMO!!!
  model.SetNodeTransform(
    0, 0, -5,  # Translation
    0, angle.cfloat, 0,   # Rotation
    1, 1, 1 )  # Scale
  angle += 1

  # self.model.UpdateModel(ModelUpdateFlags.Geometry)
  self.camera.Render()
  self.window.glSwapWindow()
  horde3d.FinalizeFrame()  # TODO: is this needed?

{.experimental.}
method `=destroy`*(self: ref VideoSystem) {.base.} =
  sdl.quitSubSystem(sdl.INIT_VIDEO)
  horde3d.Release()
  logging.debug("Video system unloaded")
