import sdl2.sdl
import logging
import strformat
import os
import ospaths
import sequtils
import typetraits

import ../../wrappers/horde3d/horde3d
import ../../core/messages
import ../../systems
import ../../config
import ../input/sdl as sdl_input


type
  Window* = tuple[
    x, y, width, height: int,
    fullscreen: bool,
  ]

  VideoSystem* = object of System
    camera*: horde3d.Node
    window: sdl.Window
    pipelineResource, fontResource, panelResource: horde3d.Res

  Video* = object {.inheritable.}
    node*: horde3d.Node


let assetsDir = getAppDir() / "assets" / "video"


# ---- Component ----
method init*(self: ref Video) {.base.} =
  raise newException(LibraryError, "Not implemented")

method dispose*(self: ref Video) {.base.} =
  logging.debug "Destroying video component"
  self.node.removeNode()


# ---- System ----
proc updateViewport*(self: ref VideoSystem, width, height: int) =
  ## Updates camera viewport
  self.camera.setNodeParamI(horde3d.Camera.ViewportXI, 0)
  self.camera.setNodeParamI(horde3d.Camera.ViewportYI, 0)
  self.camera.setNodeParamI(horde3d.Camera.ViewportWidthI, width)
  self.camera.setNodeParamI(horde3d.Camera.ViewportHeightI, height)
  self.camera.setupCameraView(45.0, width.float / height.float, 0.5, 2048.0)

  self.pipelineResource.resizePipelineBuffers(width, height)

proc loadResources*(self: ref VideoSystem) =
  # TODO: think of better resource management
  logging.debug "Loading resources from " & assetsDir
  if not utLoadResourcesFromDisk(assetsDir):
    raise newException(LibraryError, "Could not load resources")

# type
#   Resource* = tuple[kind: ResTypes, path: string]
#
# proc get*(self: Resource): horde3d.Res =
#   ## Gets resource from horde3d resource manager or tries to load it.
#   ## Raises exception if resource could not be loaded.
#   # TODO: check whether it works fine
#   result = horde3d.FindResource(self.kind, self.path)
#   if result == 0:
#     result = horde3d.AddResource(self.kind, self.path, 0)
#     logging.debug "LOADED RES: " & $result

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
      (sdl.WINDOW_SHOWN or sdl.WINDOW_OPENGL or sdl.WINDOW_RESIZABLE or (if window.fullscreen: sdl.WINDOW_FULLSCREEN_DESKTOP else: 0)).uint32,
    )
    if self.window == nil:
      raise newException(LibraryError, "Could not create SDL window")

    if sdl.glCreateContext(self.window) == nil:
      raise newException(LibraryError, "Could not create SDL OpenGL context")

    if sdl.setRelativeMouseMode(true) != 0:
      raise newException(LibraryError, "Could not enable relative mouse mode")

  except LibraryError:
    logging.fatal getCurrentExceptionMsg() & ": " & $sdl.getError()
    sdl.quitSubSystem(sdl.INIT_VIDEO)
    raise

  logging.debug "SDL video system initialized"

  # ---- Horde3d ----
  logging.debug "Initializing " & $horde3d.getVersionString()

  try:
    if not horde3d.init(horde3d.RenderDevice.OpenGL4):
      raise newException(LibraryError, "Could not init Horde3D: " & $horde3d.getError())

    # load default resources
    self.pipelineResource = addResource(ResTypes.Pipeline, "pipelines/forward.pipeline.xml")
    self.fontResource = addResource(ResTypes.Material, "overlays/font.material.xml")
    self.panelResource = addResource(ResTypes.Material,  "overlays/panel.material.xml")
    if @[self.pipelineResource, self.fontResource, self.panelResource].any(proc (res: Res): bool = res == 0):
      raise newException(LibraryError, "Could not add one or more resources")

    self.loadResources()

    # DEMO
    logging.debug "Adding light to the scene"
    var light = RootNode.addLightNode("light", 0, "LIGHTING", "SHADOWMAP")
    light.setNodeTransform(0.0, 20.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0)
    light.setNodeParamF(Light.RadiusF, 0, 50.0)

    # setting up camera
    self.camera = horde3d.RootNode.addCameraNode("camera", self.pipelineResource)
    self.updateViewport(window.width, window.height)

  except LibraryError:
    horde3d.release()
    logging.fatal getCurrentExceptionMsg()
    raise

  logging.debug "Horde3d initialized"

  procCall self.as(ref System).init()

method update*(self: ref VideoSystem, dt: float) =
  procCall self.as(ref System).update(dt)

  if config.logLevel <= lvlDebug:
    horde3d.utShowFrameStats(self.fontResource, self.panelResource, 1)

  # self.model.UpdateModel(ModelUpdateFlags.Geometry)
  self.camera.render()
  self.window.glSwapWindow()
  horde3d.finalizeFrame()  # TODO: is this needed?
  horde3d.clearOverlays()

proc `=destroy`*(self: var VideoSystem) =
  horde3d.release()
  sdl.quitSubSystem(sdl.INIT_VIDEO)
  logging.debug "Video system unloaded"

# ---- component ----
method transform*(
  self: var Video,
  translation: tuple[x, y, z: float] = (0.0, 0.0, 0.0),
  rotation: tuple[x, y, z: float] = (0.0, 0.0, 0.0),
  scale: tuple[x, y, z: float] = (1.0, 1.0, 1.0)
) {.base.} =
  self.node.setNodeTransform(
    translation.x, translation.y, translation.z,
    rotation.x, rotation.y, rotation.z,
    scale.x, scale.y, scale.z,
  )


# ---- handlers ----
method process*(self: ref VideoSystem, message: ref WindowResizeMessage) =
  self.updateViewport(message.width, message.height)
