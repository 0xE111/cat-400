# Source: https://github.com/zacharycarter/bgfx.nim

{.deadCodeElim: on.}
when defined(windows):
  const bgfxdll* = "libbgfx.dll"
elif defined(macosx):
  const bgfxdll* = "libbgfx.dylib"
else:
  const bgfxdll* = "libbgfx.so"

import defines
export defines

type va_list* {.importc,header:"<stdarg.h>".} = object

type
  renderer_type_t* {.size: sizeof(cint).} = enum
    RENDERER_TYPE_NOOP, RENDERER_TYPE_DIRECT3D9,
    RENDERER_TYPE_DIRECT3D11, RENDERER_TYPE_DIRECT3D12,
    RENDERER_TYPE_GNM, RENDERER_TYPE_METAL, RENDERER_TYPE_OPENGLES,
    RENDERER_TYPE_OPENGL, RENDERER_TYPE_VULKAN, RENDERER_TYPE_COUNT
  access_t* {.size: sizeof(cint).} = enum
    ACCESS_READ, ACCESS_WRITE, ACCESS_READWRITE, ACCESS_COUNT
  attrib_t* {.size: sizeof(cint).} = enum
    ATTRIB_POSITION, ATTRIB_NORMAL, ATTRIB_TANGENT,
    ATTRIB_BITANGENT, ATTRIB_COLOR0, ATTRIB_COLOR1,
    ATTRIB_COLOR2, ATTRIB_COLOR3, ATTRIB_INDICES,
    ATTRIB_WEIGHT, ATTRIB_TEXCOORD0, ATTRIB_TEXCOORD1,
    ATTRIB_TEXCOORD2, ATTRIB_TEXCOORD3, ATTRIB_TEXCOORD4,
    ATTRIB_TEXCOORD5, ATTRIB_TEXCOORD6, ATTRIB_TEXCOORD7,
    ATTRIB_COUNT
  attrib_type_t* {.size: sizeof(cint).} = enum
    ATTRIB_TYPE_UINT8, ATTRIB_TYPE_UINT10, ATTRIB_TYPE_INT16,
    ATTRIB_TYPE_HALF, ATTRIB_TYPE_FLOAT, ATTRIB_TYPE_COUNT
  texture_format_t* {.size: sizeof(cint).} = enum
    TEXTURE_FORMAT_BC1, TEXTURE_FORMAT_BC2, TEXTURE_FORMAT_BC3,
    TEXTURE_FORMAT_BC4, TEXTURE_FORMAT_BC5, TEXTURE_FORMAT_BC6H,
    TEXTURE_FORMAT_BC7, TEXTURE_FORMAT_ETC1, TEXTURE_FORMAT_ETC2,
    TEXTURE_FORMAT_ETC2A, TEXTURE_FORMAT_ETC2A1,
    TEXTURE_FORMAT_PTC12, TEXTURE_FORMAT_PTC14,
    TEXTURE_FORMAT_PTC12A, TEXTURE_FORMAT_PTC14A,
    TEXTURE_FORMAT_PTC22, TEXTURE_FORMAT_PTC24, TEXTURE_FORMAT_ATC,
    TEXTURE_FORMAT_ATCE, TEXTURE_FORMAT_ATCI,
    TEXTURE_FORMAT_ASTC4x4, TEXTURE_FORMAT_ASTC5x5,
    TEXTURE_FORMAT_ASTC6x6, TEXTURE_FORMAT_ASTC8x5,
    TEXTURE_FORMAT_ASTC8x6, TEXTURE_FORMAT_ASTC10x5,
    TEXTURE_FORMAT_UNKNOWN, TEXTURE_FORMAT_R1, TEXTURE_FORMAT_A8,
    TEXTURE_FORMAT_R8, TEXTURE_FORMAT_R8I, TEXTURE_FORMAT_R8U,
    TEXTURE_FORMAT_R8S, TEXTURE_FORMAT_R16, TEXTURE_FORMAT_R16I,
    TEXTURE_FORMAT_R16U, TEXTURE_FORMAT_R16F, TEXTURE_FORMAT_R16S,
    TEXTURE_FORMAT_R32I, TEXTURE_FORMAT_R32U, TEXTURE_FORMAT_R32F,
    TEXTURE_FORMAT_RG8, TEXTURE_FORMAT_RG8I, TEXTURE_FORMAT_RG8U,
    TEXTURE_FORMAT_RG8S, TEXTURE_FORMAT_RG16, TEXTURE_FORMAT_RG16I,
    TEXTURE_FORMAT_RG16U, TEXTURE_FORMAT_RG16F,
    TEXTURE_FORMAT_RG16S, TEXTURE_FORMAT_RG32I,
    TEXTURE_FORMAT_RG32U, TEXTURE_FORMAT_RG32F,
    TEXTURE_FORMAT_RGB8, TEXTURE_FORMAT_RGB8I,
    TEXTURE_FORMAT_RGB8U, TEXTURE_FORMAT_RGB8S,
    TEXTURE_FORMAT_RGB9E5F, TEXTURE_FORMAT_BGRA8,
    TEXTURE_FORMAT_RGBA8, TEXTURE_FORMAT_RGBA8I,
    TEXTURE_FORMAT_RGBA8U, TEXTURE_FORMAT_RGBA8S,
    TEXTURE_FORMAT_RGBA16, TEXTURE_FORMAT_RGBA16I,
    TEXTURE_FORMAT_RGBA16U, TEXTURE_FORMAT_RGBA16F,
    TEXTURE_FORMAT_RGBA16S, TEXTURE_FORMAT_RGBA32I,
    TEXTURE_FORMAT_RGBA32U, TEXTURE_FORMAT_RGBA32F,
    TEXTURE_FORMAT_R5G6B5, TEXTURE_FORMAT_RGBA4,
    TEXTURE_FORMAT_RGB5A1, TEXTURE_FORMAT_RGB10A2,
    TEXTURE_FORMAT_RG11B10F, TEXTURE_FORMAT_UNKNOWN_DEPTH,
    TEXTURE_FORMAT_D16, TEXTURE_FORMAT_D24, TEXTURE_FORMAT_D24S8,
    TEXTURE_FORMAT_D32, TEXTURE_FORMAT_D16F, TEXTURE_FORMAT_D24F,
    TEXTURE_FORMAT_D32F, TEXTURE_FORMAT_D0S8, TEXTURE_FORMAT_COUNT
  uniform_type_t* {.size: sizeof(cint).} = enum
    UNIFORM_TYPE_INT1, UNIFORM_TYPE_END, UNIFORM_TYPE_VEC4,
    UNIFORM_TYPE_MAT3, UNIFORM_TYPE_MAT4, UNIFORM_TYPE_COUNT
  backbuffer_ratio_t* {.size: sizeof(cint).} = enum
    BACKBUFFER_RATIO_EQUAL, BACKBUFFER_RATIO_HALF,
    BACKBUFFER_RATIO_QUARTER, BACKBUFFER_RATIO_EIGHTH,
    BACKBUFFER_RATIO_SIXTEENTH, BACKBUFFER_RATIO_DOUBLE,
    BACKBUFFER_RATIO_COUNT
  occlusion_query_result_t* {.size: sizeof(cint).} = enum
    OCCLUSION_QUERY_RESULT_INVISIBLE, OCCLUSION_QUERY_RESULT_VISIBLE,
    OCCLUSION_QUERY_RESULT_NORESULT, OCCLUSION_QUERY_RESULT_COUNT
  topology_t* {.size: sizeof(cint).} = enum
    TOPOLOGY_TRI_LIST, TOPOLOGY_TRI_STRIP, TOPOLOGY_LINE_LIST,
    TOPOLOGY_LINE_STRIP, TOPOLOGY_POINT_LIST, TOPOLOGY_COUNT
  topology_convert_t* {.size: sizeof(cint).} = enum
    TOPOLOGY_CONVERT_TRI_LIST_FLIP_WINDING,
    TOPOLOGY_CONVERT_TRI_STRIP_FLIP_WINDING,
    TOPOLOGY_CONVERT_TRI_LIST_TO_LINE_LIST,
    TOPOLOGY_CONVERT_TRI_STRIP_TO_TRI_LIST,
    TOPOLOGY_CONVERT_LINE_STRIP_TO_LINE_LIST, TOPOLOGY_CONVERT_COUNT
  topology_sort_t* {.size: sizeof(cint).} = enum
    TOPOLOGY_SORT_DIRECTION_FRONT_TO_BACK_MIN,
    TOPOLOGY_SORT_DIRECTION_FRONT_TO_BACK_AVG,
    TOPOLOGY_SORT_DIRECTION_FRONT_TO_BACK_MAX,
    TOPOLOGY_SORT_DIRECTION_BACK_TO_FRONT_MIN,
    TOPOLOGY_SORT_DIRECTION_BACK_TO_FRONT_AVG,
    TOPOLOGY_SORT_DIRECTION_BACK_TO_FRONT_MAX,
    TOPOLOGY_SORT_DISTANCE_FRONT_TO_BACK_MIN,
    TOPOLOGY_SORT_DISTANCE_FRONT_TO_BACK_AVG,
    TOPOLOGY_SORT_DISTANCE_FRONT_TO_BACK_MAX,
    TOPOLOGY_SORT_DISTANCE_BACK_TO_FRONT_MIN,
    TOPOLOGY_SORT_DISTANCE_BACK_TO_FRONT_AVG,
    TOPOLOGY_SORT_DISTANCE_BACK_TO_FRONT_MAX, TOPOLOGY_SORT_COUNT
  view_mode_t* {.size: sizeof(cint).} = enum
    VIEW_MODE_DEFAULT, VIEW_MODE_SEQUENTIAL,
    VIEW_MODE_DEPTH_ASCENDING, VIEW_MODE_DEPTH_DESCENDING,
    VIEW_MODE_CCOUNT

  encoder_s* {.bycopy.} = object

  dynamic_index_buffer_handle_t* {.bycopy.} = object
    idx*: uint16

  dynamic_vertex_buffer_handle_t* {.bycopy.} = object
    idx*: uint16

  frame_buffer_handle_t* {.bycopy.} = object
    idx*: uint16

  index_buffer_handle_t* {.bycopy.} = object
    idx*: uint16

  indirect_buffer_handle_t* {.bycopy.} = object
    idx*: uint16

  occlusion_query_handle_t* {.bycopy.} = object
    idx*: uint16

  program_handle_t* {.bycopy.} = object
    idx*: uint16

  shader_handle_t* {.bycopy.} = object
    idx*: uint16

  texture_handle_t* {.bycopy.} = object
    idx*: uint16

  uniform_handle_t* {.bycopy.} = object
    idx*: uint16

  vertex_buffer_handle_t* {.bycopy.} = object
    idx*: uint16

  vertex_decl_handle_t* {.bycopy.} = object
    idx*: uint16

  release_fn_t* = proc (`ptr`: pointer; userData: pointer)
  memory_t* {.bycopy.} = object
    data*: ptr uint8
    size*: uint32

  transform_t* {.bycopy.} = object
    data*: ptr cfloat
    num*: uint16

  view_id_t* = uint16
  view_stats_t* {.bycopy.} = object
    name*: array[256, char]
    view*: view_id_t
    cpuTimeElapsed*: int64
    gpuTimeElapsed*: int64

  encoder_stats_t* {.bycopy.} = object
    cpuTimeBegin*: int64
    cpuTimeEnd*: int64

  stats_t* {.bycopy.} = object
    cpuTimeFrame*: int64
    cpuTimeBegin*: int64
    cpuTimeEnd*: int64
    cpuTimerFreq*: int64
    gpuTimeBegin*: int64
    gpuTimeEnd*: int64
    gpuTimerFreq*: int64
    waitRender*: int64
    waitSubmit*: int64
    numDraw*: uint32
    numCompute*: uint32
    numBlit*: uint32
    maxGpuLatency*: uint32
    numDynamicIndexBuffers*: uint16
    numDynamicVertexBuffers*: uint16
    numFrameBuffers*: uint16
    numIndexBuffers*: uint16
    numOcclusionQueries*: uint16
    numPrograms*: uint16
    numShaders*: uint16
    numTextures*: uint16
    numUniforms*: uint16
    numVertexBuffers*: uint16
    numVertexDecls*: uint16
    textureMemoryUsed*: int64
    rtMemoryUsed*: int64
    transientVbUsed*: int32
    transientIbUsed*: int32
    numPrims*: array[TOPOLOGY_COUNT, uint32]
    gpuMemoryMax*: int64
    gpuMemoryUsed*: int64
    width*: uint16
    height*: uint16
    textWidth*: uint16
    textHeight*: uint16
    numViews*: uint16
    viewStats*: ptr view_stats_t
    numEncoders*: uint8
    encoderStats*: ptr encoder_stats_t

  vertex_decl_t* {.bycopy.} = object
    hash*: uint32
    stride*: uint16
    offset*: array[ATTRIB_COUNT, uint16]
    attributes*: array[ATTRIB_COUNT, uint16]

  transient_index_buffer_t* {.bycopy.} = object
    data*: ptr uint8
    size*: uint32
    handle*: index_buffer_handle_t
    startIndex*: uint32

  transient_vertex_buffer_t* {.bycopy.} = object
    data*: ptr uint8
    size*: uint32
    startVertex*: uint32
    stride*: uint16
    handle*: vertex_buffer_handle_t
    decl*: vertex_decl_handle_t

  instance_data_buffer_t* {.bycopy.} = object
    data*: ptr uint8
    size*: uint32
    offset*: uint32
    num*: uint32
    stride*: uint16
    handle*: vertex_buffer_handle_t

  texture_info_t* {.bycopy.} = object
    format*: texture_format_t
    storageSize*: uint32
    width*: uint16
    height*: uint16
    depth*: uint16
    numLayers*: uint16
    numMips*: uint8
    bitsPerPixel*: uint8
    cubeMap*: bool

  uniform_info_t* {.bycopy.} = object
    name*: array[256, char]
    `type`*: uniform_type_t
    num*: uint16

  attachment_t* {.bycopy.} = object
    access*: access_t
    handle*: texture_handle_t
    mip*: uint16
    layer*: uint16
    resolve*: uint8

  caps_gpu_t* {.bycopy.} = object
    vendorId*: uint16
    deviceId*: uint16

  caps_limits_t* {.bycopy.} = object
    maxDrawCalls*: uint32
    maxBlits*: uint32
    maxTextureSize*: uint32
    maxTextureLayers*: uint32
    maxViews*: uint32
    maxFrameBuffers*: uint32
    maxFBAttachments*: uint32
    maxPrograms*: uint32
    maxShaders*: uint32
    maxTextures*: uint32
    maxTextureSamplers*: uint32
    maxComputeBindings*: uint32
    maxVertexDecls*: uint32
    maxVertexStreams*: uint32
    maxIndexBuffers*: uint32
    maxVertexBuffers*: uint32
    maxDynamicIndexBuffers*: uint32
    maxDynamicVertexBuffers*: uint32
    maxUniforms*: uint32
    maxOcclusionQueries*: uint32
    maxEncoders*: uint32
    transientVbSize*: uint32
    transientIbSize*: uint32

  caps_t* {.bycopy.} = object
    rendererType*: renderer_type_t
    supported*: uint64
    vendorId*: uint16
    deviceId*: uint16
    homogeneousDepth*: bool
    originBottomLeft*: bool
    numGPUs*: uint8
    gpu*: array[4, caps_gpu_t]
    limits*: caps_limits_t
    formats*: array[TEXTURE_FORMAT_COUNT, uint16]

  fatal_t* {.size: sizeof(cint).} = enum
    FATAL_DEBUG_CHECK, FATAL_INVALID_SHADER,
    FATAL_UNABLE_TO_INITIALIZE, FATAL_UNABLE_TO_CREATE_TEXTURE,
    FATAL_DEVICE_LOST, FATAL_COUNT
  callback_interface_t* {.bycopy.} = object
    vtbl*: ptr callback_vtbl_t

  callback_vtbl_t* {.bycopy.} = object
    fatal*: proc (this: ptr callback_interface_t; filePath: cstring; line: uint16; code: fatal_t; str: cstring)
    trace_vargs*: proc (this: ptr callback_interface_t; filePath: cstring; line: uint16; format: cstring; argList: va_list)
    profiler_begin*: proc (this: ptr callback_interface_t; name: cstring; abgr: uint32; filePath: cstring; line: uint16)
    profiler_begin_literal*: proc (this: ptr callback_interface_t; name: cstring; abgr: uint32; filePath: cstring; line: uint16)
    profiler_end*: proc (this: ptr callback_interface_t)
    cache_read_size*: proc (this: ptr callback_interface_t; id: uint64): uint32
    cache_read*: proc (this: ptr callback_interface_t; id: uint64; data: pointer; size: uint32): bool
    cache_write*: proc (this: ptr callback_interface_t; id: uint64; data: pointer; size: uint32)
    screen_shot*: proc (this: ptr callback_interface_t; filePath: cstring; width: uint32; height: uint32; pitch: uint32; data: pointer; size: uint32; yflip: bool)
    capture_begin*: proc (this: ptr callback_interface_t; width: uint32; height: uint32; pitch: uint32; format: texture_format_t; yflip: bool)
    capture_end*: proc (this: ptr callback_interface_t)
    capture_frame*: proc (this: ptr callback_interface_t; data: pointer; size: uint32)

  allocator_interface_t* {.bycopy.} = object
    vtbl*: ptr allocator_vtbl_t

  allocator_vtbl_t* {.bycopy.} = object
    realloc*: proc (this: ptr allocator_interface_t; `ptr`: pointer; size: csize; align: csize; file: cstring; line: uint32): pointer

  platform_data_t* {.bycopy.} = object
    ndt*: pointer
    nwh*: pointer
    context*: pointer
    backBuffer*: pointer
    backBufferDS*: pointer

  resolution_t* {.bycopy.} = object
    format*: texture_format_t
    width*: uint32
    height*: uint32
    reset*: uint32
    numBackBuffers*: uint8
    maxFrameLatency*: uint8

  init_limits_t* {.bycopy.} = object
    maxEncoders*: uint16
    transientVbSize*: uint32
    transientIbSize*: uint32

  init_t* {.bycopy.} = object
    `type`*: renderer_type_t
    vendorId*: uint16
    deviceId*: uint16
    debug*: bool
    profile*: bool
    platformData*: platform_data_t
    resolution*: resolution_t
    limits*: init_limits_t
    callback*: ptr callback_interface_t
    allocator*: ptr allocator_interface_t

{.push cdecl, dynlib:bgfxdll.}
proc vertex_decl_begin*(decl: ptr vertex_decl_t;renderer: renderer_type_t) {.importc: "bgfx_vertex_decl_begin".}
proc vertex_decl_add*(decl: ptr vertex_decl_t; attrib: attrib_t; num: uint8; `type`: attrib_type_t; normalized: bool; asInt: bool) {.importc: "bgfx_vertex_decl_add".}
proc vertex_decl_decode*(decl: ptr vertex_decl_t; attrib: attrib_t; num: ptr uint8; `type`: ptr attrib_type_t; normalized: ptr bool; asInt: ptr bool) {.importc: "bgfx_vertex_decl_decode".}
proc vertex_decl_has*(decl: ptr vertex_decl_t; attrib: attrib_t): bool {.importc: "bgfx_vertex_decl_has".}
proc vertex_decl_skip*(decl: ptr vertex_decl_t; num: uint8) {.importc: "bgfx_vertex_decl_skip".}
proc vertex_decl_end*(decl: ptr vertex_decl_t) {.importc: "bgfx_vertex_decl_end".}
proc vertex_pack*(input: array[4, cfloat]; inputNormalized: bool; attr: attrib_t; decl: ptr vertex_decl_t; data: pointer; index: uint32) {.importc: "bgfx_vertex_pack".}
proc vertex_unpack*(output: array[4, cfloat]; attr: attrib_t; decl: ptr vertex_decl_t; data: pointer; index: uint32) {.importc: "bgfx_vertex_unpack".}
proc vertex_convert*(destDecl: ptr vertex_decl_t; destData: pointer; srcDecl: ptr vertex_decl_t; srcData: pointer; num: uint32) {.importc: "bgfx_vertex_convert".}
proc weld_vertices*(output: ptr uint16; decl: ptr vertex_decl_t; data: pointer; num: uint16; epsilon: cfloat): uint16 {.importc: "bgfx_weld_vertices".}
proc topology_convert*(conversion: topology_convert_t; dst: pointer; dstSize: uint32; indices: pointer; numIndices: uint32; index32: bool): uint32 {.importc: "bgfx_topology_convert".}
proc topology_sort_tri_list*(sort: topology_sort_t; dst: pointer; dstSize: uint32; dir: array[3, cfloat]; pos: array[3, cfloat]; vertices: pointer; stride: uint32; indices: pointer; numIndices: uint32; index32: bool) {.importc: "bgfx_topology_sort_tri_list".}
proc get_supported_renderers*(max: uint8; `enum`: ptr renderer_type_t): uint8 {.importc: "bgfx_get_supported_renderers".}
proc get_renderer_name*(`type`: renderer_type_t): cstring {.importc: "bgfx_get_renderer_name".}
proc init_ctor*(init: ptr init_t) {.importc: "bgfx_init_ctor".}
proc init*(init: ptr init_t): bool {.importc: "bgfx_init".}
proc shutdown*() {.importc: "bgfx_shutdown".}
proc reset*(width: uint32; height: uint32; flags: uint32; format: texture_format_t) {.importc: "bgfx_reset".}
proc begin*(): ptr encoder_s {.importc: "bgfx_begin".}
proc `end`*(encoder: ptr encoder_s) {.importc: "bgfx_end".}
proc frame*(capture: bool): uint32 {.importc: "bgfx_frame".}
proc get_renderer_type*(): renderer_type_t {.importc: "bgfx_get_renderer_type".}
proc get_caps*(): ptr caps_t {.importc: "bgfx_get_caps".}
proc get_stats*(): ptr stats_t {.importc: "bgfx_get_stats".}
proc alloc*(size: uint32): ptr memory_t {.importc: "bgfx_alloc".}
proc copy*(data: pointer; size: uint32): ptr memory_t {.importc: "bgfx_copy".}
proc make_ref*(data: pointer; size: uint32): ptr memory_t {.importc: "bgfx_make_ref".}
proc make_ref_release*(data: pointer; size: uint32; releaseFn: release_fn_t; userData: pointer): ptr memory_t {.importc: "bgfx_make_ref_release".}
proc set_debug*(debug: uint32) {.importc: "bgfx_set_debug".}
proc dbg_text_clear*(attr: uint8; small: bool) {.importc: "bgfx_dbg_text_clear".}
proc dbg_text_printf*(x: uint16; y: uint16; attr: uint8; format: cstring) {.varargs,
    importc: "bgfx_dbg_text_printf".}
proc dbg_text_vprintf*(x: uint16; y: uint16; attr: uint8; format: cstring; argList: va_list) {.importc: "bgfx_dbg_text_vprintf".}
proc dbg_text_image*(x: uint16; y: uint16; width: uint16; height: uint16; data: pointer; pitch: uint16) {.importc: "bgfx_dbg_text_image".}
proc create_index_buffer*(mem: ptr memory_t; flags: uint16): index_buffer_handle_t {.importc: "bgfx_create_index_buffer".}
proc destroy_index_buffer*(handle: index_buffer_handle_t) {.importc: "bgfx_destroy_index_buffer".}
proc create_vertex_buffer*(mem: ptr memory_t; decl: ptr vertex_decl_t; flags: uint16): vertex_buffer_handle_t {.importc: "bgfx_create_vertex_buffer".}
proc destroy_vertex_buffer*(handle: vertex_buffer_handle_t) {.importc: "bgfx_destroy_vertex_buffer".}
proc create_dynamic_index_buffer*(num: uint32; flags: uint16): dynamic_index_buffer_handle_t {.importc: "bgfx_create_dynamic_index_buffer".}
proc create_dynamic_index_buffer_mem*(mem: ptr memory_t; flags: uint16): dynamic_index_buffer_handle_t {.importc: "bgfx_create_dynamic_index_buffer_mem".}
proc update_dynamic_index_buffer*(handle: dynamic_index_buffer_handle_t; startIndex: uint32; mem: ptr memory_t) {.importc: "bgfx_update_dynamic_index_buffer".}
proc destroy_dynamic_index_buffer*(handle: dynamic_index_buffer_handle_t) {.importc: "bgfx_destroy_dynamic_index_buffer".}
proc create_dynamic_vertex_buffer*(num: uint32; decl: ptr vertex_decl_t; flags: uint16): dynamic_vertex_buffer_handle_t {.importc: "bgfx_create_dynamic_vertex_buffer".}
proc create_dynamic_vertex_buffer_mem*(mem: ptr memory_t; decl: ptr vertex_decl_t; flags: uint16): dynamic_vertex_buffer_handle_t {.importc: "bgfx_create_dynamic_vertex_buffer_mem".}
proc update_dynamic_vertex_buffer*(handle: dynamic_vertex_buffer_handle_t; startVertex: uint32; mem: ptr memory_t) {.importc: "bgfx_update_dynamic_vertex_buffer".}
proc destroy_dynamic_vertex_buffer*(handle: dynamic_vertex_buffer_handle_t) {.importc: "bgfx_destroy_dynamic_vertex_buffer".}
proc get_avail_transient_index_buffer*(num: uint32): uint32 {.importc: "bgfx_get_avail_transient_index_buffer".}
proc get_avail_transient_vertex_buffer*(num: uint32; decl: ptr vertex_decl_t): uint32 {.importc: "bgfx_get_avail_transient_vertex_buffer".}
proc get_avail_instance_data_buffer*(num: uint32; stride: uint16): uint32 {.importc: "bgfx_get_avail_instance_data_buffer".}
proc alloc_transient_index_buffer*(tib: ptr transient_index_buffer_t; num: uint32) {.importc: "bgfx_alloc_transient_index_buffer".}
proc alloc_transient_vertex_buffer*(tvb: ptr transient_vertex_buffer_t; num: uint32; decl: ptr vertex_decl_t) {.importc: "bgfx_alloc_transient_vertex_buffer".}
proc alloc_transient_buffers*(tvb: ptr transient_vertex_buffer_t; decl: ptr vertex_decl_t; numVertices: uint32; tib: ptr transient_index_buffer_t; numIndices: uint32): bool {.importc: "bgfx_alloc_transient_buffers".}
proc alloc_instance_data_buffer*(idb: ptr instance_data_buffer_t; num: uint32; stride: uint16) {.importc: "bgfx_alloc_instance_data_buffer".}
proc create_indirect_buffer*(num: uint32): indirect_buffer_handle_t {.importc: "bgfx_create_indirect_buffer".}
proc destroy_indirect_buffer*(handle: indirect_buffer_handle_t) {.importc: "bgfx_destroy_indirect_buffer".}
proc create_shader*(mem: ptr memory_t): shader_handle_t {.importc: "bgfx_create_shader".}
proc get_shader_uniforms*(handle: shader_handle_t; uniforms: ptr uniform_handle_t; max: uint16): uint16 {.importc: "bgfx_get_shader_uniforms".}
proc get_uniform_info*(handle: uniform_handle_t; info: ptr uniform_info_t) {.importc: "bgfx_get_uniform_info".}
proc set_shader_name*(handle: shader_handle_t; name: cstring; len: int32) {.importc: "bgfx_set_shader_name".}
proc destroy_shader*(handle: shader_handle_t) {.importc: "bgfx_destroy_shader".}
proc create_program*(vsh: shader_handle_t; fsh: shader_handle_t; destroyShaders: bool): program_handle_t {.importc: "bgfx_create_program".}
proc create_compute_program*(csh: shader_handle_t; destroyShaders: bool): program_handle_t {.importc: "bgfx_create_compute_program".}
proc destroy_program*(handle: program_handle_t) {.importc: "bgfx_destroy_program".}
proc is_texture_valid*(depth: uint16; cubeMap: bool; numLayers: uint16; format: texture_format_t; flags: uint64): bool {.importc: "bgfx_is_texture_valid".}
proc calc_texture_size*(info: ptr texture_info_t; width: uint16; height: uint16; depth: uint16; cubeMap: bool; hasMips: bool; numLayers: uint16; format: texture_format_t) {.importc: "bgfx_calc_texture_size".}
proc create_texture*(mem: ptr memory_t; flags: uint64; skip: uint8; info: ptr texture_info_t): texture_handle_t {.importc: "bgfx_create_texture".}
proc create_texture_2d*(width: uint16; height: uint16; hasMips: bool; numLayers: uint16; format: texture_format_t; flags: uint64; mem: ptr memory_t): texture_handle_t {.importc: "bgfx_create_texture_2d".}
proc create_texture_2d_scaled*(ratio: backbuffer_ratio_t; hasMips: bool; numLayers: uint16; format: texture_format_t; flags: uint64): texture_handle_t {.importc: "bgfx_create_texture_2d_scaled".}
proc create_texture_3d*(width: uint16; height: uint16; depth: uint16; hasMips: bool; format: texture_format_t; flags: uint64; mem: ptr memory_t): texture_handle_t {.importc: "bgfx_create_texture_3d".}
proc create_texture_cube*(size: uint16; hasMips: bool; numLayers: uint16; format: texture_format_t; flags: uint64; mem: ptr memory_t): texture_handle_t {.importc: "bgfx_create_texture_cube".}
proc update_texture_2d*(handle: texture_handle_t; layer: uint16; mip: uint8; x: uint16; y: uint16; width: uint16; height: uint16; mem: ptr memory_t; pitch: uint16) {.importc: "bgfx_update_texture_2d".}
proc update_texture_3d*(handle: texture_handle_t; mip: uint8; x: uint16; y: uint16; z: uint16; width: uint16; height: uint16; depth: uint16; mem: ptr memory_t) {.importc: "bgfx_update_texture_3d".}
proc update_texture_cube*(handle: texture_handle_t; layer: uint16; side: uint8; mip: uint8; x: uint16; y: uint16; width: uint16; height: uint16; mem: ptr memory_t; pitch: uint16) {.importc: "bgfx_update_texture_cube".}
proc read_texture*(handle: texture_handle_t; data: pointer; mip: uint8): uint32 {.importc: "bgfx_read_texture".}
proc set_texture_name*(handle: texture_handle_t; name: cstring; len: int32) {.importc: "bgfx_set_texture_name".}
proc destroy_texture*(handle: texture_handle_t) {.importc: "bgfx_destroy_texture".}
proc create_frame_buffer*(width: uint16; height: uint16; format: texture_format_t; textureFlags: uint64): frame_buffer_handle_t {.importc: "bgfx_create_frame_buffer".}
proc create_frame_buffer_scaled*(ratio: backbuffer_ratio_t; format: texture_format_t; textureFlags: uint64): frame_buffer_handle_t {.importc: "bgfx_create_frame_buffer_scaled".}
proc create_frame_buffer_from_handles*(num: uint8; handles: ptr texture_handle_t; destroyTextures: bool): frame_buffer_handle_t {.importc: "bgfx_create_frame_buffer_from_handles".}
proc create_frame_buffer_from_attachment*(num: uint8; attachment: ptr attachment_t; destroyTextures: bool): frame_buffer_handle_t {.importc: "bgfx_create_frame_buffer_from_attachment".}
proc create_frame_buffer_from_nwh*(nwh: pointer; width: uint16; height: uint16; format: texture_format_t; depthFormat: texture_format_t): frame_buffer_handle_t {.importc: "bgfx_create_frame_buffer_from_nwh".}
proc get_texture*(handle: frame_buffer_handle_t; attachment: uint8): texture_handle_t {.importc: "bgfx_get_texture".}
proc destroy_frame_buffer*(handle: frame_buffer_handle_t) {.importc: "bgfx_destroy_frame_buffer".}
proc create_uniform*(name: cstring; `type`: uniform_type_t; num: uint16): uniform_handle_t {.importc: "bgfx_create_uniform".}
proc destroy_uniform*(handle: uniform_handle_t) {.importc: "bgfx_destroy_uniform".}
proc create_occlusion_query*(): occlusion_query_handle_t {.importc: "bgfx_create_occlusion_query".}
proc get_result*(handle: occlusion_query_handle_t; result: ptr int32): occlusion_query_result_t {.importc: "bgfx_get_result".}
proc destroy_occlusion_query*(handle: occlusion_query_handle_t) {.importc: "bgfx_destroy_occlusion_query".}
proc set_palette_color*(index: uint8; rgba: array[4, cfloat]) {.importc: "bgfx_set_palette_color".}
proc set_view_name*(id: view_id_t; name: cstring) {.importc: "bgfx_set_view_name".}
proc set_view_rect*(id: view_id_t; x: uint16; y: uint16; width: uint16; height: uint16) {.importc: "bgfx_set_view_rect".}
proc set_view_rect_auto*(id: view_id_t; x: uint16; y: uint16; ratio: backbuffer_ratio_t) {.importc: "bgfx_set_view_rect_auto".}
proc set_view_scissor*(id: view_id_t; x: uint16; y: uint16; width: uint16; height: uint16) {.importc: "bgfx_set_view_scissor".}
proc set_view_clear*(id: view_id_t; flags: uint16; rgba: uint32; depth: cfloat; stencil: uint8) {.importc: "bgfx_set_view_clear".}
proc set_view_clear_mrt*(id: view_id_t; flags: uint16; depth: cfloat; stencil: uint8; v0: uint8; v1: uint8; v2: uint8; v3: uint8; v4: uint8; v5: uint8; v6: uint8; v7: uint8) {.importc: "bgfx_set_view_clear_mrt".}
proc set_view_mode*(id: view_id_t; mode: view_mode_t) {.importc: "bgfx_set_view_mode".}
proc set_view_frame_buffer*(id: view_id_t; handle: frame_buffer_handle_t) {.importc: "bgfx_set_view_frame_buffer".}
proc set_view_transform*(id: view_id_t; view: pointer; proj: pointer) {.importc: "bgfx_set_view_transform".}
proc set_view_transform_stereo*(id: view_id_t; view: pointer; projL: pointer; flags: uint8; projR: pointer) {.importc: "bgfx_set_view_transform_stereo".}
proc set_view_order*(id: view_id_t; num: uint16; order: ptr view_id_t) {.importc: "bgfx_set_view_order".}
proc reset_view*(id: view_id_t) {.importc: "bgfx_reset_view".}
proc set_marker*(marker: cstring) {.importc: "bgfx_set_marker".}
proc set_state*(state: uint64; rgba: uint32) {.importc: "bgfx_set_state".}
proc set_condition*(handle: occlusion_query_handle_t; visible: bool) {.importc: "bgfx_set_condition".}
proc set_stencil*(fstencil: uint32; bstencil: uint32) {.importc: "bgfx_set_stencil".}
proc set_scissor*(x: uint16; y: uint16; width: uint16; height: uint16): uint16 {.importc: "bgfx_set_scissor".}
proc set_scissor_cached*(cache: uint16) {.importc: "bgfx_set_scissor_cached".}
proc set_transform*(mtx: pointer; num: uint16): uint32 {.importc: "bgfx_set_transform".}
proc alloc_transform*(transform: ptr transform_t; num: uint16): uint32 {.importc: "bgfx_alloc_transform".}
proc set_transform_cached*(cache: uint32; num: uint16) {.importc: "bgfx_set_transform_cached".}
proc set_uniform*(handle: uniform_handle_t; value: pointer; num: uint16) {.importc: "bgfx_set_uniform".}
proc set_index_buffer*(handle: index_buffer_handle_t; firstIndex: uint32; numIndices: uint32) {.importc: "bgfx_set_index_buffer".}
proc set_dynamic_index_buffer*(handle: dynamic_index_buffer_handle_t; firstIndex: uint32; numIndices: uint32) {.importc: "bgfx_set_dynamic_index_buffer".}
proc set_transient_index_buffer*(tib: ptr transient_index_buffer_t; firstIndex: uint32; numIndices: uint32) {.importc: "bgfx_set_transient_index_buffer".}
proc set_vertex_buffer*(stream: uint8; handle: vertex_buffer_handle_t; startVertex: uint32; numVertices: uint32) {.importc: "bgfx_set_vertex_buffer".}
proc set_dynamic_vertex_buffer*(stream: uint8; handle: dynamic_vertex_buffer_handle_t; startVertex: uint32; numVertices: uint32) {.importc: "bgfx_set_dynamic_vertex_buffer".}
proc set_transient_vertex_buffer*(stream: uint8; tvb: ptr transient_vertex_buffer_t; startVertex: uint32; numVertices: uint32) {.importc: "bgfx_set_transient_vertex_buffer".}
proc set_vertex_count*(numVertices: uint32) {.importc: "bgfx_set_vertex_count".}
proc set_instance_data_buffer*(idb: ptr instance_data_buffer_t; start: uint32; num: uint32) {.importc: "bgfx_set_instance_data_buffer".}
proc set_instance_data_from_vertex_buffer*(handle: vertex_buffer_handle_t; startVertex: uint32; num: uint32) {.importc: "bgfx_set_instance_data_from_vertex_buffer".}
proc set_instance_data_from_dynamic_vertex_buffer*(handle: dynamic_vertex_buffer_handle_t; startVertex: uint32; num: uint32) {.importc: "bgfx_set_instance_data_from_dynamic_vertex_buffer".}
proc set_instance_count*(numInstances: uint32) {.importc: "bgfx_set_instance_count".}
proc set_texture*(stage: uint8; sampler: uniform_handle_t; handle: texture_handle_t; flags: uint32) {.importc: "bgfx_set_texture".}
proc touch*(id: view_id_t) {.importc: "bgfx_touch".}
proc submit*(id: view_id_t; handle: program_handle_t; depth: uint32; preserveState: bool) {.importc: "bgfx_submit".}
proc submit_occlusion_query*(id: view_id_t; program: program_handle_t; occlusionQuery: occlusion_query_handle_t; depth: uint32; preserveState: bool) {.importc: "bgfx_submit_occlusion_query".}
proc submit_indirect*(id: view_id_t; handle: program_handle_t; indirectHandle: indirect_buffer_handle_t; start: uint16; num: uint16; depth: uint32; preserveState: bool) {.importc: "bgfx_submit_indirect".}
proc set_image*(stage: uint8; handle: texture_handle_t; mip: uint8; access: access_t; format: texture_format_t) {.importc: "bgfx_set_image".}
proc set_compute_index_buffer*(stage: uint8; handle: index_buffer_handle_t; access: access_t) {.importc: "bgfx_set_compute_index_buffer".}
proc set_compute_vertex_buffer*(stage: uint8; handle: vertex_buffer_handle_t; access: access_t) {.importc: "bgfx_set_compute_vertex_buffer".}
proc set_compute_dynamic_index_buffer*(stage: uint8; handle: dynamic_index_buffer_handle_t; access: access_t) {.importc: "bgfx_set_compute_dynamic_index_buffer".}
proc set_compute_dynamic_vertex_buffer*(stage: uint8; handle: dynamic_vertex_buffer_handle_t; access: access_t) {.importc: "bgfx_set_compute_dynamic_vertex_buffer".}
proc set_compute_indirect_buffer*(stage: uint8; handle: indirect_buffer_handle_t; access: access_t) {.importc: "bgfx_set_compute_indirect_buffer".}
proc dispatch*(id: view_id_t; handle: program_handle_t; numX: uint32; numY: uint32; numZ: uint32; flags: uint8) {.importc: "bgfx_dispatch".}
proc dispatch_indirect*(id: view_id_t; handle: program_handle_t; indirectHandle: indirect_buffer_handle_t; start: uint16; num: uint16; flags: uint8) {.importc: "bgfx_dispatch_indirect".}
proc `discard`*() {.importc: "bgfx_discard".}
proc blit*(id: view_id_t; dst: texture_handle_t; dstMip: uint8; dstX: uint16; dstY: uint16; dstZ: uint16; src: texture_handle_t; srcMip: uint8; srcX: uint16; srcY: uint16; srcZ: uint16; width: uint16; height: uint16; depth: uint16) {.importc: "bgfx_blit".}
proc encoder_set_marker*(encoder: ptr encoder_s; marker: cstring) {.importc: "bgfx_encoder_set_marker".}
proc encoder_set_state*(encoder: ptr encoder_s; state: uint64; rgba: uint32) {.importc: "bgfx_encoder_set_state".}
proc encoder_set_condition*(encoder: ptr encoder_s; handle: occlusion_query_handle_t; visible: bool) {.importc: "bgfx_encoder_set_condition".}
proc encoder_set_stencil*(encoder: ptr encoder_s; fstencil: uint32; bstencil: uint32) {.importc: "bgfx_encoder_set_stencil".}
proc encoder_set_scissor*(encoder: ptr encoder_s; x: uint16; y: uint16; width: uint16; height: uint16): uint16 {.importc: "bgfx_encoder_set_scissor".}
proc encoder_set_scissor_cached*(encoder: ptr encoder_s; cache: uint16) {.importc: "bgfx_encoder_set_scissor_cached".}
proc encoder_set_transform*(encoder: ptr encoder_s; mtx: pointer; num: uint16): uint32 {.importc: "bgfx_encoder_set_transform".}
proc encoder_alloc_transform*(encoder: ptr encoder_s; transform: ptr transform_t; num: uint16): uint32 {.importc: "bgfx_encoder_alloc_transform".}
proc encoder_set_transform_cached*(encoder: ptr encoder_s; cache: uint32; num: uint16) {.importc: "bgfx_encoder_set_transform_cached".}
proc encoder_set_uniform*(encoder: ptr encoder_s; handle: uniform_handle_t; value: pointer; num: uint16) {.importc: "bgfx_encoder_set_uniform".}
proc encoder_set_index_buffer*(encoder: ptr encoder_s; handle: index_buffer_handle_t; firstIndex: uint32; numIndices: uint32) {.importc: "bgfx_encoder_set_index_buffer".}
proc encoder_set_dynamic_index_buffer*(encoder: ptr encoder_s; handle: dynamic_index_buffer_handle_t; firstIndex: uint32; numIndices: uint32) {.importc: "bgfx_encoder_set_dynamic_index_buffer".}
proc encoder_set_transient_index_buffer*(encoder: ptr encoder_s; tib: ptr transient_index_buffer_t; firstIndex: uint32; numIndices: uint32) {.importc: "bgfx_encoder_set_transient_index_buffer".}
proc encoder_set_vertex_buffer*(encoder: ptr encoder_s; stream: uint8; handle: vertex_buffer_handle_t; startVertex: uint32; numVertices: uint32) {.importc: "bgfx_encoder_set_vertex_buffer".}
proc encoder_set_dynamic_vertex_buffer*(encoder: ptr encoder_s; stream: uint8; handle: dynamic_vertex_buffer_handle_t; startVertex: uint32; numVertices: uint32) {.importc: "bgfx_encoder_set_dynamic_vertex_buffer".}
proc encoder_set_transient_vertex_buffer*(encoder: ptr encoder_s; stream: uint8; tvb: ptr transient_vertex_buffer_t; startVertex: uint32; numVertices: uint32) {.importc: "bgfx_encoder_set_transient_vertex_buffer".}
proc encoder_set_vertex_count*(encoder: ptr encoder_s; numVertices: uint32) {.importc: "bgfx_encoder_set_vertex_count".}
proc encoder_set_instance_data_buffer*(encoder: ptr encoder_s; idb: ptr instance_data_buffer_t; start: uint32; num: uint32) {.importc: "bgfx_encoder_set_instance_data_buffer".}
proc encoder_set_instance_data_from_vertex_buffer*(encoder: ptr encoder_s; handle: vertex_buffer_handle_t; startVertex: uint32; num: uint32) {.importc: "bgfx_encoder_set_instance_data_from_vertex_buffer".}
proc encoder_set_instance_data_from_dynamic_vertex_buffer*(encoder: ptr encoder_s; handle: dynamic_vertex_buffer_handle_t; startVertex: uint32; num: uint32) {.importc: "bgfx_encoder_set_instance_data_from_dynamic_vertex_buffer".}
proc encoder_set_texture*(encoder: ptr encoder_s; stage: uint8; sampler: uniform_handle_t; handle: texture_handle_t; flags: uint32) {.importc: "bgfx_encoder_set_texture".}
proc encoder_touch*(encoder: ptr encoder_s; id: view_id_t) {.importc: "bgfx_encoder_touch".}
proc encoder_submit*(encoder: ptr encoder_s; id: view_id_t; handle: program_handle_t; depth: uint32; preserveState: bool) {.importc: "bgfx_encoder_submit".}
proc encoder_submit_occlusion_query*(encoder: ptr encoder_s; id: view_id_t; program: program_handle_t; occlusionQuery: occlusion_query_handle_t; depth: uint32; preserveState: bool) {.importc: "bgfx_encoder_submit_occlusion_query".}
proc encoder_submit_indirect*(encoder: ptr encoder_s; id: view_id_t; handle: program_handle_t; indirectHandle: indirect_buffer_handle_t; start: uint16; num: uint16; depth: uint32; preserveState: bool) {.importc: "bgfx_encoder_submit_indirect".}
proc encoder_set_image*(encoder: ptr encoder_s; stage: uint8; handle: texture_handle_t; mip: uint8; access: access_t; format: texture_format_t) {.importc: "bgfx_encoder_set_image".}
proc encoder_set_compute_index_buffer*(encoder: ptr encoder_s; stage: uint8; handle: index_buffer_handle_t; access: access_t) {.importc: "bgfx_encoder_set_compute_index_buffer".}
proc encoder_set_compute_vertex_buffer*(encoder: ptr encoder_s; stage: uint8; handle: vertex_buffer_handle_t; access: access_t) {.importc: "bgfx_encoder_set_compute_vertex_buffer".}
proc encoder_set_compute_dynamic_index_buffer*(encoder: ptr encoder_s; stage: uint8; handle: dynamic_index_buffer_handle_t; access: access_t) {.importc: "bgfx_encoder_set_compute_dynamic_index_buffer".}
proc encoder_set_compute_dynamic_vertex_buffer*(encoder: ptr encoder_s; stage: uint8; handle: dynamic_vertex_buffer_handle_t; access: access_t) {.importc: "bgfx_encoder_set_compute_dynamic_vertex_buffer".}
proc encoder_set_compute_indirect_buffer*(encoder: ptr encoder_s; stage: uint8; handle: indirect_buffer_handle_t; access: access_t) {.importc: "bgfx_encoder_set_compute_indirect_buffer".}
proc encoder_dispatch*(encoder: ptr encoder_s; id: view_id_t; handle: program_handle_t; numX: uint32; numY: uint32; numZ: uint32; flags: uint8) {.importc: "bgfx_encoder_dispatch".}
proc encoder_dispatch_indirect*(encoder: ptr encoder_s; id: view_id_t; handle: program_handle_t; indirectHandle: indirect_buffer_handle_t; start: uint16; num: uint16; flags: uint8) {.importc: "bgfx_encoder_dispatch_indirect".}
proc encoder_discard*(encoder: ptr encoder_s) {.importc: "bgfx_encoder_discard".}
proc encoder_blit*(encoder: ptr encoder_s; id: view_id_t; dst: texture_handle_t; dstMip: uint8; dstX: uint16; dstY: uint16; dstZ: uint16; src: texture_handle_t; srcMip: uint8; srcX: uint16; srcY: uint16; srcZ: uint16; width: uint16; height: uint16; depth: uint16) {.importc: "bgfx_encoder_blit".}
proc request_screen_shot*(handle: frame_buffer_handle_t; filePath: cstring) {.importc: "bgfx_request_screen_shot".}
{.pop.}
