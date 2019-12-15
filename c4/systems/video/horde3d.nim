# ================== WARNING ================== #
#         This module is unmaintained           #
# ============================================= #

import logging
import strformat
import os
import sequtils

import sdl2/sdl as sdllib

import ../../lib/horde3d/horde3d
import ../../entities
import ../../systems
import ../input/sdl


type
  Window* = tuple[
    x, y, width, height: int,
    fullscreen: bool,
  ]

  Horde3dVideoSystem* = object of System
    camera*: horde3d.Node
    window: sdllib.Window
    pipelineResource, fontResource, panelResource: horde3d.Res

  Video* = object {.inheritable.}
    node*: horde3d.Node


let assetsDir = getAppDir() / "assets" / "video"


# ---- Component ----

method dispose*(self: ref Video) {.base.} =
  logging.debug "Destroying video component"
  self.node.removeNode()


# ---- System ----
proc updateViewport*(self: var Horde3dVideoSystem, width, height: int) =
  ## Updates camera viewport
  # TODO: no hardcoding
  self.camera.setNodeParamI(horde3d.Camera.ViewportXI, 0)
  self.camera.setNodeParamI(horde3d.Camera.ViewportYI, 0)
  self.camera.setNodeParamI(horde3d.Camera.ViewportWidthI, width)
  self.camera.setNodeParamI(horde3d.Camera.ViewportHeightI, height)
  self.camera.setupCameraView(45.0, width.float / height.float, 0.5, 2048.0)

  self.pipelineResource.resizePipelineBuffers(width, height)

proc loadResources*(self: var Horde3dVideoSystem) =
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

proc init*(self: var Horde3dVideoSystem) =
  # ---- SDL ----
  logging.debug "Initializing SDL video system"

  try:
    if initSubSystem(INIT_VIDEO) != 0:
      raise newException(LibraryError, "Could not init SDL video subsystem")

    # var displayMode: DisplayMode
    # if getCurrentDisplayMode(0, displayMode.addr) != 0:
    #   raise newException(LibraryError, "Could not get current display mode: " & $getError())

    self.window = createWindow(
      &"TODO: title",
      100,  # window.x,
      100,  # window.y,
      800,  # window.width,
      600,  # window.height,
      (WINDOW_SHOWN or WINDOW_OPENGL or WINDOW_RESIZABLE or WINDOW_FULLSCREEN_DESKTOP).uint32,
    )
    if self.window.isNil:
      raise newException(LibraryError, "Could not create SDL window")

    if glCreateContext(self.window) == nil:
      raise newException(LibraryError, "Could not create SDL OpenGL context")

    if setRelativeMouseMode(true) != 0:
      raise newException(LibraryError, "Could not enable relative mouse mode")

  except LibraryError:
    logging.fatal getCurrentExceptionMsg() & ": " & $getError()
    quitSubSystem(INIT_VIDEO)
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
    self.updateViewport(800, 600)

  except LibraryError:
    horde3d.release()
    logging.fatal getCurrentExceptionMsg()
    raise

  logging.debug "Horde3d initialized"


method update*(self: ref Horde3dVideoSystem, dt: float) =
  # if logLevel <= lvlDebug:
  horde3d.utShowFrameStats(self.fontResource, self.panelResource, 1)

  # self.model.UpdateModel(ModelUpdateFlags.Geometry)
  self.camera.render()
  self.window.glSwapWindow()
  horde3d.finalizeFrame()  # TODO: is this needed?
  horde3d.clearOverlays()

proc `=destroy`*(self: var Horde3dVideoSystem) =
  horde3d.release()
  quitSubSystem(INIT_VIDEO)
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
method process*(self: ref Horde3dVideoSystem, message: ref WindowResizeMessage) =
  self.updateViewport(message.width, message.height)
