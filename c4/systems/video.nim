import sdl2.sdl
import "../wrappers/horde3d/horde3d"

from logging import debug, fatal
from strformat import `&`
from os import getAppDir
from ospaths import `/`
from "../core/messages" import Message, `$`
from "../systems" import System, init, update
import "../config"


type
  Window* = tuple[
    x, y, width, height: int,
    fullscreen: bool,
  ]

  VideoSystem* = object of System
    window: sdl.Window
    pipeline: horde3d.Res
    camera*: horde3d.Node

  Video* {.inheritable.} = object
    node: horde3d.Node


const
  forwardPipeline = staticRead("../wrappers/horde3d/assets/pipelines/forward.pipeline.xml")

let
  assetsDir = getAppDir() / "assets/video"
  
var
  fontRes, panelRes, cubeRes: horde3d.Res


method init*(self: ref VideoSystem) =
  # ---- SDL ----
  logging.debug "Initializing SDL video system"

  let window = config.settings.video.window  # just an alias

  try:
    if sdl.initSubSystem(sdl.INIT_VIDEO) != 0:
      raise newException(LibraryError, "Could not init SDL video subsystem" & $sdl.getError())

    # var displayMode: sdl.DisplayMode
    # if sdl.getCurrentDisplayMode(0, displayMode.addr) != 0:
    #   raise newException(LibraryError, "Could not get current display mode: " & $sdl.getError())
  
    self.window = sdl.createWindow(
      &"{config.title} v{config.version}",
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

    fontRes = AddResource(ResTypes.Material, "overlays/font.material.xml", 0.cint)
    panelRes = AddResource(ResTypes.Material, "overlays/panel.material.xml", 0.cint)
    cubeRes = AddResource(ResTypes.SceneGraph, "models/cube/cube.scene.xml", 0.cint)
    
    logging.debug("Searching for assets in " & assetsDir)
    if not utLoadResourcesFromDisk(assetsDir):
      raise newException(LibraryError, "Could not load resources")

    # DEMO
    logging.debug "Adding light to the scene"
    var light = RootNode.AddLightNode("light", 0.cint, "LIGHTING", "SHADOWMAP")
    light.SetNodeTransform(0.cfloat, 20.cfloat, 0.cfloat, 0.cfloat, 0.cfloat, 0.cfloat, 1.cfloat, 1.cfloat, 1.cfloat)
    light.SetNodeParamF(Light.RadiusF, 0.cint, 50.cfloat)

    # setting up camera
    self.camera = horde3d.RootNode.AddCameraNode("camera", self.pipeline)
    self.camera.SetNodeParamI(horde3d.Camera.ViewportXI, 0.cint)
    self.camera.SetNodeParamI(horde3d.Camera.ViewportYI, 0.cint)
    self.camera.SetNodeParamI(horde3d.Camera.ViewportWidthI, window.width.cint)
    self.camera.SetNodeParamI(horde3d.Camera.ViewportHeightI, window.height.cint)
    self.camera.SetupCameraView(45.cfloat, (window.width/window.height).cfloat, (0.5).cfloat, 2048.cfloat)

    self.pipeline.ResizePipelineBuffers(window.width.cint, window.height.cint)

  except LibraryError:
    horde3d.Release()
    logging.fatal(getCurrentExceptionMsg())
    raise

  logging.debug "Horde3d initialized"

  procCall ((ref System)self).init()

method update*(self: ref VideoSystem, dt: float) =
  procCall ((ref System)self).update(dt)

  horde3d.utShowFrameStats(fontRes, panelRes, 1)
  # # DEMO!!!
  # model.SetNodeTransform(
  #   0, 0, -5,  # Translation
  #   0, 0, 0,   # Rotation
  #   1, 1, 1 )  # Scale

  # self.model.UpdateModel(ModelUpdateFlags.Geometry)
  self.camera.Render()
  self.window.glSwapWindow()
  horde3d.FinalizeFrame()  # TODO: is this needed?
  horde3d.ClearOverlays()

{.experimental.}
method `=destroy`*(self: ref VideoSystem) {.base.} =
  sdl.quitSubSystem(sdl.INIT_VIDEO)
  horde3d.Release()
  logging.debug("Video system unloaded")


proc init*(self: var Video) =
  logging.debug "Adding node to scene"
  self.node = RootNode.AddNodes(cubeRes)

proc transform*(
  self: var Video,
  translation: tuple[x, y, z: float] = (0.0, 0.0, 0.0),
  rotation: tuple[x, y, z: float] = (0.0, 0.0, 0.0),
  scale: tuple[x, y, z: float] = (1.0, 1.0, 1.0)
) =
  self.node.SetNodeTransform(
    translation.x, translation.y, translation.z,
    rotation.x, rotation.y, rotation.z,
    scale.x, scale.y, scale.z,
  )

proc `=destroy`*(self: var Video) =
  self.node.RemoveNode()
