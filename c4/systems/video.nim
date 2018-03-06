import sdl2.sdl
import "../wrappers/horde3d/horde3d"
import logging
from "../conf" import Window
import strformat
from os import getAppDir
from ospaths import `/`


var
  window: sdl.Window
  pipeline: horde3d.Res
  camera: horde3d.Node
  # DEMO!!!
  model: horde3d.Node  
  angle: int


const
  forwardPipeline = staticRead("../wrappers/horde3d/assets/pipelines/forward.pipeline.xml")

let
  assetsDir = getAppDir() / "assets/video"


proc init*(
  title: string,
  windowConfig: conf.Window,
) =
  # ---- SDL ----
  logging.debug("Initializing SDL video system")

  try:
    if sdl.initSubSystem(sdl.INIT_VIDEO) != 0:
      raise newException(LibraryError, "Could not init SDL video subsystem" & $sdl.getError())

    # var displayMode: sdl.DisplayMode
    # if sdl.getCurrentDisplayMode(0, displayMode.addr) != 0:
    #   raise newException(LibraryError, "Could not get current display mode: " & $sdl.getError())
  
    window = sdl.createWindow(
      title,
      windowConfig.x.cint,
      windowConfig.y.cint,
      windowConfig.width.cint,
      windowConfig.height.cint,
      (sdl.WINDOW_SHOWN or sdl.WINDOW_OPENGL or (if windowConfig.fullscreen: sdl.WINDOW_FULLSCREEN_DESKTOP else: 0)).uint32,
    )
    if window == nil:
      raise newException(LibraryError, "Could not create SDL window: " & $sdl.getError())

    if sdl.glCreateContext(window) == nil:
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
    pipeline = horde3d.AddResource(horde3d.ResTypes.Pipeline, "pipelines/forward.pipeline.xml", 0.cint)
    if not pipeline.LoadResource(forwardPipeline, forwardPipeline.len + 1):
      raise newException(LibraryError, "Could not load Horde3D resources")

    # DEMO!!!
    var modelRes = AddResource(ResTypes.SceneGraph, "models/man/man.scene.xml", 0.cint)
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
    camera = horde3d.RootNode.AddCameraNode("camera", pipeline)
    camera.SetNodeParamI(horde3d.Camera.ViewportXI, 0.cint)
    camera.SetNodeParamI(horde3d.Camera.ViewportYI, 0.cint)
    camera.SetNodeParamI(horde3d.Camera.ViewportWidthI, 400.cint)
    camera.SetNodeParamI(horde3d.Camera.ViewportHeightI, 300.cint)
    camera.SetupCameraView(45.cfloat, (400/300).cfloat, (0.5).cfloat, 2048.cfloat)

    pipeline.ResizePipelineBuffers(400.cint, 300.cint)


  except LibraryError:
    horde3d.Release()
    logging.fatal(getCurrentExceptionMsg())
    raise

  logging.debug("Horde3d initialized")
 
proc update*(dt: float) =
  # DEMO!!!
  model.SetNodeTransform(
    0, -1, -5,  # Translation
    0, angle.cfloat, 0,   # Rotation
    1, 1, 1 )  # Scale
  angle += 1

  # self.model.UpdateModel(ModelUpdateFlags.Geometry)
  camera.Render()
  window.glSwapWindow()
  horde3d.FinalizeFrame()  # TODO: is this needed?

proc release*() =
  sdl.quitSubSystem(sdl.INIT_VIDEO)
  horde3d.Release()
  logging.debug("Video system unloaded")
