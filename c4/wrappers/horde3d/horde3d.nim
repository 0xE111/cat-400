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
{.push cdecl, dynlib:lib.}
proc getVersionString*(): cstring {.importc: "h3dGetVersionString".}
proc checkExtension*(extensionName: cstring): bool {.importc: "h3dCheckExtension".}
proc getError*(): bool {.importc: "h3dGetError".}
proc init*(deviceType: RenderDevice): bool {.importc: "h3dInit".}
proc release*() {.importc: "h3dRelease".}
proc compute*(materialRes: Res; context: cstring; groupX: cint; groupY: cint; groupZ: cint) {.importc: "h3dCompute".}
proc render*(cameraNode: Node) {.importc: "h3dRender".}
proc finalizeFrame*() {.importc: "h3dFinalizeFrame".}
proc clear*() {.importc: "h3dClear".}
proc getMessage*(level: ptr cint; time: ptr cfloat): cstring {.importc: "h3dGetMessage".}
proc getOption*(param: Options): cfloat {.importc: "h3dGetOption".}
proc setOption*(param: Options; value: cfloat): bool {.importc: "h3dSetOption".}
proc getStat*(param: Stats; reset: bool): cfloat {.importc: "h3dGetStat".}
proc getDeviceCapabilities*(param: DeviceCapabilities): cfloat {.importc: "h3dGetDeviceCapabilities".}
proc showOverlays*(verts: ptr cfloat; vertCount: cint; colR: cfloat; colG: cfloat; colB: cfloat; colA: cfloat; materialRes: Res; flags: cint) {.importc: "h3dShowOverlays".}
proc clearOverlays*() {.importc: "h3dClearOverlays".}
proc getResType*(res: Res): cint {.importc: "h3dGetResType".}
proc getResName*(res: Res): cstring {.importc: "h3dGetResName".}
proc getNextResource*(`type`: cint|ResTypes; start: Res): Res {.importc: "h3dGetNextResource".}
proc findResource*(`type`: cint|ResTypes; name: cstring): Res {.importc: "h3dFindResource".}
proc addResource*(`type`: cint|ResTypes; name: cstring; flags: cint = 0): Res {.importc: "h3dAddResource".}
proc cloneResource*(sourceRes: Res; name: cstring): Res {.importc: "h3dCloneResource".}
proc removeResource*(res: Res): cint {.importc: "h3dRemoveResource".}
proc isResLoaded*(res: Res): bool {.importc: "h3dIsResLoaded".}
proc loadResource*(res: Res; data: cstring; size: cint): bool {.importc: "h3dLoadResource".}
proc unloadResource*(res: Res) {.importc: "h3dUnloadResource".}
proc getResElemCount*(res: Res; elem: cint): cint {.importc: "h3dGetResElemCount".}
proc findResElem*(res: Res; elem: cint; param: cint; value: cstring): cint {.importc: "h3dFindResElem".}
proc getResParamI*(res: Res; elem: cint; elemIdx: cint; param: cint): cint {.importc: "h3dGetResParamI".}
proc setResParamI*(res: Res; elem: cint; elemIdx: cint; param: cint; value: cint) {.importc: "h3dSetResParamI".}
proc getResParamF*(res: Res; elem: cint; elemIdx: cint; param: cint; compIdx: cint): cfloat {.importc: "h3dGetResParamF".}
proc setResParamF*(res: Res; elem: cint; elemIdx: cint; param: cint; compIdx: cint; value: cfloat) {.importc: "h3dSetResParamF".}
proc getResParamStr*(res: Res; elem: cint; elemIdx: cint; param: cint): cstring {.importc: "h3dGetResParamStr".}
proc setResParamStr*(res: Res; elem: cint; elemIdx: cint; param: cint; value: cstring) {.importc: "h3dSetResParamStr".}
proc mapResStream*(res: Res; elem: cint; elemIdx: cint; stream: cint; read: bool; write: bool): pointer {.importc: "h3dMapResStream".}
proc unmapResStream*(res: Res) {.importc: "h3dUnmapResStream".}
proc queryUnloadedResource*(index: cint): Res {.importc: "h3dQueryUnloadedResource".}
proc releaseUnusedResources*() {.importc: "h3dReleaseUnusedResources".}
proc createTexture*(name: cstring; width: cint; height: cint; fmt: cint; flags: cint): Res {.importc: "h3dCreateTexture".}
proc setShaderPreambles*(vertPreamble: cstring; fragPreamble: cstring; geomPreamble: cstring; tessControlPreamble: cstring; tessEvalPreamble: cstring; computePreamble: cstring) {.importc: "h3dSetShaderPreambles".}
proc setMaterialUniform*(materialRes: Res; name: cstring; a: cfloat; b: cfloat; c: cfloat; d: cfloat): bool {.importc: "h3dSetMaterialUniform".}
proc resizePipelineBuffers*(pipeRes: Res; width: cint; height: cint) {.importc: "h3dResizePipelineBuffers".}
proc getRenderTargetData*(pipelineRes: Res; targetName: cstring; bufIndex: cint; width: ptr cint; height: ptr cint; compCount: ptr cint; dataBuffer: pointer; bufferSize: cint): bool {.importc: "h3dGetRenderTargetData".}
proc getNodeType*(node: Node): cint {.importc: "h3dGetNodeType".}
proc getNodeParent*(node: Node): Node {.importc: "h3dGetNodeParent".}
proc setNodeParent*(node: Node; parent: Node): bool {.importc: "h3dSetNodeParent".}
proc getNodeChild*(node: Node; index: cint): Node {.importc: "h3dGetNodeChild".}
proc addNodes*(parent: Node; sceneGraphRes: Res): Node {.importc: "h3dAddNodes".}
proc removeNode*(node: Node) {.importc: "h3dRemoveNode".}
proc checkNodeTransFlag*(node: Node; reset: bool): bool {.importc: "h3dCheckNodeTransFlag".}
proc getNodeTransform*(node: Node; tx: ptr cfloat; ty: ptr cfloat; tz: ptr cfloat; rx: ptr cfloat; ry: ptr cfloat; rz: ptr cfloat; sx: ptr cfloat; sy: ptr cfloat; sz: ptr cfloat) {.importc: "h3dGetNodeTransform".}
proc setNodeTransform*(node: Node; tx: cfloat; ty: cfloat; tz: cfloat; rx: cfloat; ry: cfloat; rz: cfloat; sx: cfloat; sy: cfloat; sz: cfloat) {.importc: "h3dSetNodeTransform".}
proc getNodeTransMats*(node: Node; relMat: ptr ptr cfloat; absMat: ptr ptr cfloat) {.importc: "h3dGetNodeTransMats".}
proc setNodeTransMat*(node: Node; mat4x4: ptr cfloat) {.importc: "h3dSetNodeTransMat".}
proc getNodeParamI*(node: Node; param: cint|Camera): cint {.importc: "h3dGetNodeParamI".}
proc setNodeParamI*(node: Node; param: cint|Camera; value: cint) {.importc: "h3dSetNodeParamI".}
proc getNodeParamF*(node: Node; param: cint|Light; compIdx: cint): cfloat {.importc: "h3dGetNodeParamF".}
proc setNodeParamF*(node: Node; param: cint|Light; compIdx: cint; value: cfloat) {.importc: "h3dSetNodeParamF".}
proc getNodeParamStr*(node: Node; param: cint): cstring {.importc: "h3dGetNodeParamStr".}
proc setNodeParamStr*(node: Node; param: cint; value: cstring) {.importc: "h3dSetNodeParamStr".}
proc getNodeFlags*(node: Node): cint {.importc: "h3dGetNodeFlags".}
proc setNodeFlags*(node: Node; flags: cint|NodeFlags; recursive: bool) {.importc: "h3dSetNodeFlags".}
proc getNodeAABB*(node: Node; minX: ptr cfloat; minY: ptr cfloat; minZ: ptr cfloat; maxX: ptr cfloat; maxY: ptr cfloat; maxZ: ptr cfloat) {.importc: "h3dGetNodeAABB".}
proc findNodes*(startNode: Node; name: cstring; `type`: cint): cint {.importc: "h3dFindNodes".}
proc getNodeFindResult*(index: cint): Node {.importc: "h3dGetNodeFindResult".}
proc setNodeUniforms*(node: Node; uniformData: ptr cfloat; count: cint) {.importc: "h3dSetNodeUniforms".}
proc castRay*(node: Node; ox: cfloat; oy: cfloat; oz: cfloat; dx: cfloat; dy: cfloat; dz: cfloat; numNearest: cint): cint {.importc: "h3dCastRay".}
proc getCastRayResult*(index: cint; node: ptr Node; distance: ptr cfloat; intersection: ptr cfloat): bool {.importc: "h3dGetCastRayResult".}
proc checkNodeVisibility*(node: Node; cameraNode: Node; checkOcclusion: bool; calcLod: bool): cint {.importc: "h3dCheckNodeVisibility".}
proc addGroupNode*(parent: Node; name: cstring): Node {.importc: "h3dAddGroupNode".}
proc addModelNode*(parent: Node; name: cstring; geometryRes: Res): Node {.importc: "h3dAddModelNode".}
proc setupModelAnimStage*(modelNode: Node; stage: cint; animationRes: Res; layer: cint; startNode: cstring; additive: bool) {.importc: "h3dSetupModelAnimStage".}
proc getModelAnimParams*(modelNode: Node; stage: cint; time: ptr cfloat; weight: ptr cfloat) {.importc: "h3dGetModelAnimParams".}
proc setModelAnimParams*(modelNode: Node; stage: cint; time: cfloat; weight: cfloat) {.importc: "h3dSetModelAnimParams".}
proc setModelMorpher*(modelNode: Node; target: cstring; weight: cfloat): bool {.importc: "h3dSetModelMorpher".}
proc updateModel*(modelNode: Node; flags: cint|ModelUpdateFlags) {.importc: "h3dUpdateModel".}
proc addMeshNode*(parent: Node; name: cstring; materialRes: Res; batchStart: cint; batchCount: cint; vertRStart: cint; vertREnd: cint): Node {.importc: "h3dAddMeshNode".}
proc addJointNode*(parent: Node; name: cstring; jointIndex: cint): Node {.importc: "h3dAddJointNode".}
proc addLightNode*(parent: Node; name: cstring; materialRes: Res; lightingContext: cstring; shadowContext: cstring): Node {.importc: "h3dAddLightNode".}
proc addCameraNode*(parent: Node; name: cstring; pipelineRes: Res): Node {.importc: "h3dAddCameraNode".}
proc setupCameraView*(cameraNode: Node; fov: cfloat; aspect: cfloat; nearDist: cfloat; farDist: cfloat) {.importc: "h3dSetupCameraView".}
proc getCameraProjMat*(cameraNode: Node; projMat: ptr cfloat) {.importc: "h3dGetCameraProjMat".}
proc setCameraProjMat*(cameraNode: Node; projMat: ptr cfloat) {.importc: "h3dSetCameraProjMat".}
proc addEmitterNode*(parent: Node; name: cstring; materialRes: Res; particleEffectRes: Res; maxParticleCount: cint; respawnCount: cint): Node {.importc: "h3dAddEmitterNode".}
proc updateEmitter*(emitterNode: Node; timeDelta: cfloat) {.importc: "h3dUpdateEmitter".}
proc hasEmitterFinished*(emitterNode: Node): bool {.importc: "h3dHasEmitterFinished".}
proc addComputeNode*(parent: Node; name: cstring; materialRes: Res; compBufferRes: Res; drawType: cint; elementsCount: cint): Node {.importc: "h3dAddComputeNode".}
{.pop.}

# ---- Terrain ----
const EXT_NodeType_Terrain*: cint = 100

type
  EXTTerrain* {.pure.} = enum
    HeightTexResI = 10000, MatResI, MeshQualityF, SkirtHeightF, BlockSizeI

{.push cdecl, dynlib:lib.}
proc extAddTerrainNode*(parent: Node; name: cstring; heightMapRes: Res; materialRes: Res): Node {.importc: "h3dextAddTerrainNode".}
proc extCreateTerrainGeoRes*(node: Node; resName: cstring; meshQuality: cfloat): Res {.importc: "h3dextCreateTerrainGeoRes".}
{.pop.}

# ---- Utils ----
const UTMaxStatMode*: cint = 2

{.push cdecl, dynlib:libUtils.}
proc utFreeMem*(`ptr`: cstringArray) {.importc: "h3dutFreeMem".}
proc utDumpMessages*(): bool {.importc: "h3dutDumpMessages".}
proc utGetResourcePath*(`type`: cint): cstring {.importc: "h3dutGetResourcePath".}
proc utSetResourcePath*(`type`: cint; path: cstring) {.importc: "h3dutSetResourcePath".}
proc utLoadResourcesFromDisk*(contentDir: cstring): bool {.importc: "h3dutLoadResourcesFromDisk".}
proc utCreateGeometryRes*(name: cstring; numVertices: cint; numTriangleIndices: cint; posData: ptr cfloat; indexData: ptr cuint; normalData: ptr cshort; tangentData: ptr cshort; bitangentData: ptr cshort; texData1: ptr cfloat; texData2: ptr cfloat): Res {.importc: "h3dutCreateGeometryRes".}
proc utCreateTGAImage*(pixels: ptr cuchar; width: cint; height: cint; bpp: cint; outData: cstringArray; outSize: ptr cint): bool {.importc: "h3dutCreateTGAImage".}
proc utScreenshot*(filename: cstring): bool {.importc: "h3dutScreenshot".}
proc utPickRay*(cameraNode: Node; nwx: cfloat; nwy: cfloat; ox: ptr cfloat; oy: ptr cfloat; oz: ptr cfloat; dx: ptr cfloat; dy: ptr cfloat; dz: ptr cfloat) {.importc: "h3dutPickRay".}
proc utPickNode*(cameraNode: Node; nwx: cfloat; nwy: cfloat): Node {.importc: "h3dutPickNode".}
proc utGetScreenshotParam*(width: ptr cint; height: ptr cint) {.importc: "h3dutGetScreenshotParam".}
proc utScreenshotRaw*(rgb: ptr cuchar; rgb_len: cint): bool {.importc: "h3dutScreenshotRaw".}
proc utShowText*(text: cstring; x: cfloat; y: cfloat; size: cfloat; colR: cfloat; colG: cfloat; colB: cfloat; fontMaterialRes: Res) {.importc: "h3dutShowText".}
proc utShowInfoBox*(x: cfloat; y: cfloat; width: cfloat; title: cstring; numRows: cint; column1: cstringArray; column2: cstringArray; fontMaterialRes: Res; panelMaterialRes: Res) {.importc: "h3dutShowInfoBox".}
proc utShowFrameStats*(fontMaterialRes: Res; panelMaterialRes: Res; mode: cint) {.importc: "h3dutShowFrameStats".}
{.pop.}
