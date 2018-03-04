import sdl2.sdl
import "../wrappers/horde3d/horde3d"
import logging
from "../conf" import Window
import strformat


type
  Video* = object
    window: sdl.Window
    pipeline: horde3d.Res
    camera: horde3d.Node


const forwardPipeline = staticRead("../wrappers/horde3d/assets/pipelines/forward.pipeline.xml")
var numInstances = 0


proc init*(
  self: var Video,
  title: string,
  window: conf.Window,
) =
  # ---- SDL ----
  logging.debug("Initializing SDL video system")
  try:
    if numInstances == 0:
      if sdl.videoInit(nil) != 0:
        raise newException(LibraryError, "Could not init SDL video subsystem" & $sdl.getError())
    numInstances += 1

    # var displayMode: sdl.DisplayMode
    # if sdl.getCurrentDisplayMode(0, displayMode.addr) != 0:
    #   raise newException(LibraryError, "Could not get current display mode: " & $sdl.getError())
  
    self.window = sdl.createWindow(
      title.cstring,
      window.x.cint,
      window.y.cint,
      window.width.cint,
      window.height.cint,
      (sdl.WINDOW_SHOWN or sdl.WINDOW_OPENGL or (if window.fullscreen: sdl.WINDOW_FULLSCREEN_DESKTOP else: 0)).uint32,
    )
    if self.window == nil:
      raise newException(LibraryError, "Could not create SDL window: " & $sdl.getError())

    if sdl.glCreateContext(self.window) == nil:
      raise newException(LibraryError, "Could not create SDL OpenGL context: " & $sdl.getError())

  except LibraryError:
    sdl.videoQuit()
    logging.fatal(getCurrentExceptionMsg())
    raise
    
  logging.debug("SDL video system initialized")

  # ---- Horde3d ----
  logging.debug("Initializing " & $horde3d.GetVersionString())

  try:
    if not horde3d.Init(horde3d.RenderDevice.OpenGL4):
      raise newException(LibraryError, "Could not init Horde3D: " & $horde3d.GetError())
  
    # load default resources
    self.pipeline = horde3d.AddResource(horde3d.ResTypes.Pipeline, "pipelines/forward".cstring, 0.cint)
    if not self.pipeline.LoadResource(forwardPipeline.cstring, forwardPipeline.len + 1):
      raise newException(LibraryError, "Could not load Horde3D resources")

    const model = staticRead("../../sample/assets/video/models/man/man.scene.xml")
    var modelRes = AddResource(ResTypes.SceneGraph, "models/man".cstring, 0.cint)
    discard modelRes.LoadResource(model.cstring, model.len + 1) 
    discard horde3d.RootNode.AddNodes(modelRes)

    # setting up camera
    self.camera = horde3d.AddCameraNode(horde3d.RootNode, "camera".cstring, self.pipeline)
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
 
proc update*(self: var Video, dt: float): bool =
  result = true

  self.camera.Render()
  self.window.glSwapWindow()
  horde3d.FinalizeFrame()  # TODO: is this needed?

{.experimental.}
proc `=destroy`*(self: var Video) =  # TODO: destructors not called!
  numInstances -= 1
  echo(&"num instances: {numInstances}")
  if numInstances == 0:
    sdl.videoQuit()
    horde3d.Release()
    logging.debug("SDL video system destroyed")
