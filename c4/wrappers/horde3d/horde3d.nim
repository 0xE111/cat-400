{.deadCodeElim: on.}
when defined(windows):
  const
    lib* = "Horde3D.dll"
    libUtils* = "Horde3DUtils.dll"
elif defined(macosx):
  const
    lib* = "libHorde3D.dylib"
    libUtils* = "libHorde3DUtils.dylib"
elif defined(unix):
  const
    lib* = "libHorde3D.so"
    libUtils* = "libHorde3DUtils.so"
else:
  {.error: "Unsupported platform".}

# ---- Main ----
type
  Res* = cint
  Node* = cint

  RenderDevice* {.size: sizeof(cint), pure.} = enum
    OpenGL2 = 2, OpenGL4 = 4

  Options* {.size: sizeof(cint), pure.} = enum
    MaxLogLevel = 1, MaxNumMessages, TrilinearFiltering, MaxAnisotropy,
    TexCompression, SRGBLinearization, LoadTextures, FastAnimation, ShadowMapSize,
    SampleCount, WireframeMode, DebugViewMode, DumpFailedShaders, GatherTimeStats

  Stats* {.size: sizeof(cint), pure.} = enum
    TriCount = 100, BatchCount, LightPassCount, FrameTime, AnimationTime,
    GeoUpdateTime, ParticleSimTime, FwdLightsGPUTime, DefLightsGPUTime,
    ShadowsGPUTime, ParticleGPUTime, TextureVMem, GeometryVMem, ComputeGPUTime

  DeviceCapabilities* {.size: sizeof(cint), pure.} = enum
    GeometryShaders = 200, TessellationShaders, ComputeShaders

  ResTypes* {.size: sizeof(cint), pure.} = enum
    Undefined = 0, SceneGraph, Geometry, Animation, Material, Code, Shader, Texture,
    ParticleEffect, Pipeline, ComputeBuffer

  ResFlags* {.size: sizeof(cint), pure.} = enum
    NoQuery = 1, NoTexCompression = 2, NoTexMipmaps = 4, TexCubemap = 8, TexDynamic = 16,
    TexRenderable = 32, TexSRGB = 64

  Formats* {.size: sizeof(cint), pure.} = enum
    Unknown = 0, TEX_BGRA8, TEX_DXT1, TEX_DXT3, TEX_DXT5, TEX_RGBA16F, TEX_RGBA32F

  GeoRes* {.size: sizeof(cint), pure.} = enum
    GeometryElem = 200, GeoIndexCountI, GeoVertexCountI, GeoIndices16I,
    GeoIndexStream, GeoVertPosStream, GeoVertTanStream, GeoVertStaticStream

  AnimRes* {.size: sizeof(cint), pure.} = enum
    EntityElem = 300, EntFrameCountI

  MatRes* {.size: sizeof(cint), pure.} = enum
    MaterialElem = 400, SamplerElem, UniformElem, MatClassStr, MatLinkI, MatShaderI,
    SampNameStr, SampTexResI, UnifNameStr, UnifValueF4

  ShaderRes* {.size: sizeof(cint), pure.} = enum
    ContextElem = 600, SamplerElem, UniformElem, ContNameStr, SampNameStr,
    SampDefTexResI, UnifNameStr, UnifSizeI, UnifDefValueF4

  TexRes* {.size: sizeof(cint), pure.} = enum
    TextureElem = 700, ImageElem, TexFormatI, TexSliceCountI, ImgWidthI, ImgHeightI,
    ImgPixelStream

  PartEffRes* {.size: sizeof(cint), pure.} = enum
    ParticleElem = 800, ChanMoveVelElem, ChanRotVelElem, ChanSizeElem, ChanColRElem,
    ChanColGElem, ChanColBElem, ChanColAElem, PartLifeMinF, PartLifeMaxF,
    ChanStartMinF, ChanStartMaxF, ChanEndRateF, ChanDragElem

  PipeRes* {.size: sizeof(cint), pure.} = enum
    StageElem = 900, StageNameStr, StageActivationI

  ComputeBufRes* {.size: sizeof(cint), pure.} = enum
    ComputeBufElem = 1000, DrawParamsElem, CompBufDataSizeI, CompBufDrawableI,
    DrawParamsNameStr, DrawParamsSizeI, DrawParamsOffsetI, DrawParamsCountI

  NodeTypes* {.size: sizeof(cint), pure.} = enum
    Undefined = 0, Group, Model, Mesh, Joint, Light, Camera, Emitter, Compute

  NodeFlags* {.size: sizeof(cint), pure.} = enum
    NoDraw = 1, NoCastShadow = 2, NoRayQuery = 4, Inactive = 7

  NodeParams* {.size: sizeof(cint), pure.} = enum
    NameStr = 1, AttachmentStr

  Model* {.size: sizeof(cint), pure.} = enum
    GeoResI = 200, SWSkinningI, LodDist1F, LodDist2F, LodDist3F, LodDist4F, AnimCountI

  Mesh* {.size: sizeof(cint), pure.} = enum
    MatResI = 300, BatchStartI, BatchCountI, VertRStartI, VertREndI, LodLevelI,
    TessellatableI

  Joint* {.size: sizeof(cint), pure.} = enum
    JointIndexI = 400

  Light* {.size: sizeof(cint), pure.} = enum
    MatResI = 500, RadiusF, FovF, ColorF3, ColorMultiplierF, ShadowMapCountI,
    ShadowSplitLambdaF, ShadowMapBiasF, LightingContextStr, ShadowContextStr

  Camera* {.size: sizeof(cint), pure.} = enum
    PipeResI = 600, OutTexResI, OutBufIndexI, LeftPlaneF, RightPlaneF, BottomPlaneF,
    TopPlaneF, NearPlaneF, FarPlaneF, ViewportXI, ViewportYI, ViewportWidthI,
    ViewportHeightI, OrthoI, OccCullingI

  Emitter* {.size: sizeof(cint), pure.} = enum
    MatResI = 700, PartEffResI, MaxCountI, RespawnCountI, DelayF, EmissionRateF,
    SpreadAngleF, ForceF3

  ComputeNode* {.size: sizeof(cint), pure.} = enum
    MatResI = 800, CompBufResI, AABBMinF, AABBMaxF, DrawTypeI, ElementsCountI

  ModelUpdateFlags* {.size: sizeof(cint), pure.} = enum
    Animation = 1, Geometry = 2

const RootNode*: Node = 1.cint

# TODO: replace cints with enums
# TODO: lower first chars of procs
{.push cdecl, dynlib:lib, importc:"h3d$1".}
proc GetVersionString*(): cstring
proc CheckExtension*(extensionName: cstring): bool
proc GetError*(): bool
proc Init*(deviceType: RenderDevice): bool
proc Release*()
proc Compute*(materialRes: Res; context: cstring; groupX: cint; groupY: cint; groupZ: cint)
proc Render*(cameraNode: Node)
proc FinalizeFrame*()
proc Clear*()
proc GetMessage*(level: ptr cint; time: ptr cfloat): cstring
proc GetOption*(param: Options): cfloat
proc SetOption*(param: Options; value: cfloat): bool
proc GetStat*(param: Stats; reset: bool): cfloat
proc GetDeviceCapabilities*(param: DeviceCapabilities): cfloat
proc ShowOverlays*(verts: ptr cfloat; vertCount: cint; colR: cfloat; colG: cfloat; colB: cfloat; colA: cfloat; materialRes: Res; flags: cint)
proc ClearOverlays*()
proc GetResType*(res: Res): cint
proc GetResName*(res: Res): cstring
proc GetNextResource*(`type`: cint|ResTypes; start: Res): Res
proc FindResource*(`type`: cint|ResTypes; name: cstring): Res
proc AddResource*(`type`: cint|ResTypes; name: cstring; flags: cint = 0): Res
proc CloneResource*(sourceRes: Res; name: cstring): Res
proc RemoveResource*(res: Res): cint
proc IsResLoaded*(res: Res): bool
proc LoadResource*(res: Res; data: cstring; size: cint): bool
proc UnloadResource*(res: Res)
proc GetResElemCount*(res: Res; elem: cint): cint
proc FindResElem*(res: Res; elem: cint; param: cint; value: cstring): cint
proc GetResParamI*(res: Res; elem: cint; elemIdx: cint; param: cint): cint
proc SetResParamI*(res: Res; elem: cint; elemIdx: cint; param: cint; value: cint)
proc GetResParamF*(res: Res; elem: cint; elemIdx: cint; param: cint; compIdx: cint): cfloat
proc SetResParamF*(res: Res; elem: cint; elemIdx: cint; param: cint; compIdx: cint; value: cfloat)
proc GetResParamStr*(res: Res; elem: cint; elemIdx: cint; param: cint): cstring
proc SetResParamStr*(res: Res; elem: cint; elemIdx: cint; param: cint; value: cstring)
proc MapResStream*(res: Res; elem: cint; elemIdx: cint; stream: cint; read: bool; write: bool): pointer
proc UnmapResStream*(res: Res)
proc QueryUnloadedResource*(index: cint): Res
proc ReleaseUnusedResources*()
proc CreateTexture*(name: cstring; width: cint; height: cint; fmt: cint; flags: cint): Res
proc SetShaderPreambles*(vertPreamble: cstring; fragPreamble: cstring; geomPreamble: cstring; tessControlPreamble: cstring; tessEvalPreamble: cstring; computePreamble: cstring)
proc SetMaterialUniform*(materialRes: Res; name: cstring; a: cfloat; b: cfloat; c: cfloat; d: cfloat): bool
proc ResizePipelineBuffers*(pipeRes: Res; width: cint; height: cint)
proc GetRenderTargetData*(pipelineRes: Res; targetName: cstring; bufIndex: cint; width: ptr cint; height: ptr cint; compCount: ptr cint; dataBuffer: pointer; bufferSize: cint): bool
proc GetNodeType*(node: Node): cint
proc GetNodeParent*(node: Node): Node
proc SetNodeParent*(node: Node; parent: Node): bool
proc GetNodeChild*(node: Node; index: cint): Node
proc AddNodes*(parent: Node; sceneGraphRes: Res): Node
proc RemoveNode*(node: Node)
proc CheckNodeTransFlag*(node: Node; reset: bool): bool
proc GetNodeTransform*(node: Node; tx: ptr cfloat; ty: ptr cfloat; tz: ptr cfloat; rx: ptr cfloat; ry: ptr cfloat; rz: ptr cfloat; sx: ptr cfloat; sy: ptr cfloat; sz: ptr cfloat)
proc SetNodeTransform*(node: Node; tx: cfloat; ty: cfloat; tz: cfloat; rx: cfloat; ry: cfloat; rz: cfloat; sx: cfloat; sy: cfloat; sz: cfloat)
proc GetNodeTransMats*(node: Node; relMat: ptr ptr cfloat; absMat: ptr ptr cfloat)
proc SetNodeTransMat*(node: Node; mat4x4: ptr cfloat)
proc GetNodeParamI*(node: Node; param: cint|Camera): cint
proc SetNodeParamI*(node: Node; param: cint|Camera; value: cint)
proc GetNodeParamF*(node: Node; param: cint|Light; compIdx: cint): cfloat
proc SetNodeParamF*(node: Node; param: cint|Light; compIdx: cint; value: cfloat)
proc GetNodeParamStr*(node: Node; param: cint): cstring
proc SetNodeParamStr*(node: Node; param: cint; value: cstring)
proc GetNodeFlags*(node: Node): cint
proc SetNodeFlags*(node: Node; flags: cint|NodeFlags; recursive: bool)
proc GetNodeAABB*(node: Node; minX: ptr cfloat; minY: ptr cfloat; minZ: ptr cfloat; maxX: ptr cfloat; maxY: ptr cfloat; maxZ: ptr cfloat)
proc FindNodes*(startNode: Node; name: cstring; `type`: cint): cint
proc GetNodeFindResult*(index: cint): Node
proc SetNodeUniforms*(node: Node; uniformData: ptr cfloat; count: cint)
proc CastRay*(node: Node; ox: cfloat; oy: cfloat; oz: cfloat; dx: cfloat; dy: cfloat; dz: cfloat; numNearest: cint): cint
proc GetCastRayResult*(index: cint; node: ptr Node; distance: ptr cfloat; intersection: ptr cfloat): bool
proc CheckNodeVisibility*(node: Node; cameraNode: Node; checkOcclusion: bool; calcLod: bool): cint
proc AddGroupNode*(parent: Node; name: cstring): Node
proc AddModelNode*(parent: Node; name: cstring; geometryRes: Res): Node
proc SetupModelAnimStage*(modelNode: Node; stage: cint; animationRes: Res; layer: cint; startNode: cstring; additive: bool)
proc GetModelAnimParams*(modelNode: Node; stage: cint; time: ptr cfloat; weight: ptr cfloat)
proc SetModelAnimParams*(modelNode: Node; stage: cint; time: cfloat; weight: cfloat)
proc SetModelMorpher*(modelNode: Node; target: cstring; weight: cfloat): bool
proc UpdateModel*(modelNode: Node; flags: cint|ModelUpdateFlags)
proc AddMeshNode*(parent: Node; name: cstring; materialRes: Res; batchStart: cint; batchCount: cint; vertRStart: cint; vertREnd: cint): Node
proc AddJointNode*(parent: Node; name: cstring; jointIndex: cint): Node
proc AddLightNode*(parent: Node; name: cstring; materialRes: Res; lightingContext: cstring; shadowContext: cstring): Node
proc AddCameraNode*(parent: Node; name: cstring; pipelineRes: Res): Node
proc SetupCameraView*(cameraNode: Node; fov: cfloat; aspect: cfloat; nearDist: cfloat; farDist: cfloat)
proc GetCameraProjMat*(cameraNode: Node; projMat: ptr cfloat)
proc SetCameraProjMat*(cameraNode: Node; projMat: ptr cfloat)
proc AddEmitterNode*(parent: Node; name: cstring; materialRes: Res; particleEffectRes: Res; maxParticleCount: cint; respawnCount: cint): Node
proc UpdateEmitter*(emitterNode: Node; timeDelta: cfloat)
proc HasEmitterFinished*(emitterNode: Node): bool
proc AddComputeNode*(parent: Node; name: cstring; materialRes: Res; compBufferRes: Res; drawType: cint; elementsCount: cint): Node
{.pop.}

# ---- Terrain ----
const EXT_NodeType_Terrain*: cint = 100

type
  EXTTerrain* {.pure.} = enum
    HeightTexResI = 10000, MatResI, MeshQualityF, SkirtHeightF, BlockSizeI

{.push cdecl, dynlib:lib, importc:"h3d$1".}
proc extAddTerrainNode*(parent: Node; name: cstring; heightMapRes: Res; materialRes: Res): Node
proc extCreateTerrainGeoRes*(node: Node; resName: cstring; meshQuality: cfloat): Res
{.pop.}

# ---- Utils ----
const UTMaxStatMode*: cint = 2

{.push cdecl, dynlib:libUtils, importc:"h3d$1".}
proc utFreeMem*(`ptr`: cstringArray)
proc utDumpMessages*(): bool
proc utGetResourcePath*(`type`: cint): cstring
proc utSetResourcePath*(`type`: cint; path: cstring)
proc utLoadResourcesFromDisk*(contentDir: cstring): bool
proc utCreateGeometryRes*(name: cstring; numVertices: cint; numTriangleIndices: cint; posData: ptr cfloat; indexData: ptr cuint; normalData: ptr cshort; tangentData: ptr cshort; bitangentData: ptr cshort; texData1: ptr cfloat; texData2: ptr cfloat): Res
proc utCreateTGAImage*(pixels: ptr cuchar; width: cint; height: cint; bpp: cint; outData: cstringArray; outSize: ptr cint): bool
proc utScreenshot*(filename: cstring): bool
proc utPickRay*(cameraNode: Node; nwx: cfloat; nwy: cfloat; ox: ptr cfloat; oy: ptr cfloat; oz: ptr cfloat; dx: ptr cfloat; dy: ptr cfloat; dz: ptr cfloat)
proc utPickNode*(cameraNode: Node; nwx: cfloat; nwy: cfloat): Node
proc utGetScreenshotParam*(width: ptr cint; height: ptr cint)
proc utScreenshotRaw*(rgb: ptr cuchar; rgb_len: cint): bool
proc utShowText*(text: cstring; x: cfloat; y: cfloat; size: cfloat; colR: cfloat; colG: cfloat; colB: cfloat; fontMaterialRes: Res)
proc utShowInfoBox*(x: cfloat; y: cfloat; width: cfloat; title: cstring; numRows: cint; column1: cstringArray; column2: cstringArray; fontMaterialRes: Res; panelMaterialRes: Res)
proc utShowFrameStats*(fontMaterialRes: Res; panelMaterialRes: Res; mode: cint)
{.pop.}
