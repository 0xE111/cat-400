##
##  Copyright 2011-2019 Branimir Karadzic. All rights reserved.
##  License: https://github.com/bkaradzic/bgfx/blob/master/LICENSE
##

{.deadCodeElim: on.}
when defined(windows):
  const lib* = "libbgfx.dll"
elif defined(macosx):
  const lib* = "libbgfx.dylib"
else:
  const lib* = "libbgfx.so"

type va_list* {.importc, header: "<stdarg.h>".} = object

when not defined(INVALID_HANDLE):
  const INVALID_HANDLE* = uint16.high

import defines
export defines

## *
##  Fatal error enum.
##
##

type
  fatal_t* {.size: sizeof(cint).} = enum
    FATAL_DEBUG_CHECK,   ## * ( 0)
    FATAL_INVALID_SHADER, ## * ( 1)
    FATAL_UNABLE_TO_INITIALIZE, ## * ( 2)
    FATAL_UNABLE_TO_CREATE_TEXTURE, ## * ( 3)
    FATAL_DEVICE_LOST,   ## * ( 4)
    FATAL_COUNT


## *
##  Renderer backend type enum.
##
##

type
  renderer_type_t* {.size: sizeof(cint).} = enum
    RENDERER_TYPE_NOOP,  ## * ( 0) No rendering.
    RENDERER_TYPE_DIRECT3D9, ## * ( 1) Direct3D 9.0
    RENDERER_TYPE_DIRECT3D11, ## * ( 2) Direct3D 11.0
    RENDERER_TYPE_DIRECT3D12, ## * ( 3) Direct3D 12.0
    RENDERER_TYPE_GNM,   ## * ( 4) GNM
    RENDERER_TYPE_METAL, ## * ( 5) Metal
    RENDERER_TYPE_NVN,   ## * ( 6) NVN
    RENDERER_TYPE_OPENGLES, ## * ( 7) OpenGL ES 2.0+
    RENDERER_TYPE_OPENGL, ## * ( 8) OpenGL 2.1+
    RENDERER_TYPE_VULKAN, ## * ( 9) Vulkan
    RENDERER_TYPE_COUNT


## *
##  Access mode enum.
##
##

type
  access_t* {.size: sizeof(cint).} = enum
    ACCESS_READ,         ## * ( 0) Read.
    ACCESS_WRITE,        ## * ( 1) Write.
    ACCESS_READWRITE,    ## * ( 2) Read and write.
    ACCESS_COUNT


## *
##  Vertex attribute enum.
##
##

type
  attrib_t* {.size: sizeof(cint).} = enum
    ATTRIB_POSITION,     ## * ( 0) a_position
    ATTRIB_NORMAL,       ## * ( 1) a_normal
    ATTRIB_TANGENT,      ## * ( 2) a_tangent
    ATTRIB_BITANGENT,    ## * ( 3) a_bitangent
    ATTRIB_COLOR0,       ## * ( 4) a_color0
    ATTRIB_COLOR1,       ## * ( 5) a_color1
    ATTRIB_COLOR2,       ## * ( 6) a_color2
    ATTRIB_COLOR3,       ## * ( 7) a_color3
    ATTRIB_INDICES,      ## * ( 8) a_indices
    ATTRIB_WEIGHT,       ## * ( 9) a_weight
    ATTRIB_TEXCOORD0,    ## * (10) a_texcoord0
    ATTRIB_TEXCOORD1,    ## * (11) a_texcoord1
    ATTRIB_TEXCOORD2,    ## * (12) a_texcoord2
    ATTRIB_TEXCOORD3,    ## * (13) a_texcoord3
    ATTRIB_TEXCOORD4,    ## * (14) a_texcoord4
    ATTRIB_TEXCOORD5,    ## * (15) a_texcoord5
    ATTRIB_TEXCOORD6,    ## * (16) a_texcoord6
    ATTRIB_TEXCOORD7,    ## * (17) a_texcoord7
    ATTRIB_COUNT


## *
##  Vertex attribute type enum.
##
##

type
  attrib_type_t* {.size: sizeof(cint).} = enum
    ATTRIB_TYPE_UINT8,   ## * ( 0) Uint8
    ATTRIB_TYPE_UINT10,  ## * ( 1) Uint10, availability depends on: `CAPS_VERTEX_ATTRIB_UINT10`.
    ATTRIB_TYPE_INT16,   ## * ( 2) Int16
    ATTRIB_TYPE_HALF,    ## * ( 3) Half, availability depends on: `CAPS_VERTEX_ATTRIB_HALF`.
    ATTRIB_TYPE_FLOAT,   ## * ( 4) Float
    ATTRIB_TYPE_COUNT


## *
##  Texture format enum.
##  Notation:
##        RGBA16S
##        ^   ^ ^
##        |   | +-- [ ]Unorm
##        |   |     [F]loat
##        |   |     [S]norm
##        |   |     [I]nt
##        |   |     [U]int
##        |   +---- Number of bits per component
##        +-------- Components
##  @attention Availability depends on Caps (see: formats).
##
##

type
  texture_format_t* {.size: sizeof(cint).} = enum
    TEXTURE_FORMAT_BC1,  ## * ( 0) DXT1
    TEXTURE_FORMAT_BC2,  ## * ( 1) DXT3
    TEXTURE_FORMAT_BC3,  ## * ( 2) DXT5
    TEXTURE_FORMAT_BC4,  ## * ( 3) LATC1/ATI1
    TEXTURE_FORMAT_BC5,  ## * ( 4) LATC2/ATI2
    TEXTURE_FORMAT_BC6H, ## * ( 5) BC6H
    TEXTURE_FORMAT_BC7,  ## * ( 6) BC7
    TEXTURE_FORMAT_ETC1, ## * ( 7) ETC1 RGB8
    TEXTURE_FORMAT_ETC2, ## * ( 8) ETC2 RGB8
    TEXTURE_FORMAT_ETC2A, ## * ( 9) ETC2 RGBA8
    TEXTURE_FORMAT_ETC2A1, ## * (10) ETC2 RGB8A1
    TEXTURE_FORMAT_PTC12, ## * (11) PVRTC1 RGB 2BPP
    TEXTURE_FORMAT_PTC14, ## * (12) PVRTC1 RGB 4BPP
    TEXTURE_FORMAT_PTC12A, ## * (13) PVRTC1 RGBA 2BPP
    TEXTURE_FORMAT_PTC14A, ## * (14) PVRTC1 RGBA 4BPP
    TEXTURE_FORMAT_PTC22, ## * (15) PVRTC2 RGBA 2BPP
    TEXTURE_FORMAT_PTC24, ## * (16) PVRTC2 RGBA 4BPP
    TEXTURE_FORMAT_ATC,  ## * (17) ATC RGB 4BPP
    TEXTURE_FORMAT_ATCE, ## * (18) ATCE RGBA 8 BPP explicit alpha
    TEXTURE_FORMAT_ATCI, ## * (19) ATCI RGBA 8 BPP interpolated alpha
    TEXTURE_FORMAT_ASTC4X4, ## * (20) ASTC 4x4 8.0 BPP
    TEXTURE_FORMAT_ASTC5X5, ## * (21) ASTC 5x5 5.12 BPP
    TEXTURE_FORMAT_ASTC6X6, ## * (22) ASTC 6x6 3.56 BPP
    TEXTURE_FORMAT_ASTC8X5, ## * (23) ASTC 8x5 3.20 BPP
    TEXTURE_FORMAT_ASTC8X6, ## * (24) ASTC 8x6 2.67 BPP
    TEXTURE_FORMAT_ASTC10X5, ## * (25) ASTC 10x5 2.56 BPP
    TEXTURE_FORMAT_UNKNOWN, ## * (26) Compressed formats above.
    TEXTURE_FORMAT_R1,   ## * (27)
    TEXTURE_FORMAT_A8,   ## * (28)
    TEXTURE_FORMAT_R8,   ## * (29)
    TEXTURE_FORMAT_R8I,  ## * (30)
    TEXTURE_FORMAT_R8U,  ## * (31)
    TEXTURE_FORMAT_R8S,  ## * (32)
    TEXTURE_FORMAT_R16,  ## * (33)
    TEXTURE_FORMAT_R16I, ## * (34)
    TEXTURE_FORMAT_R16U, ## * (35)
    TEXTURE_FORMAT_R16F, ## * (36)
    TEXTURE_FORMAT_R16S, ## * (37)
    TEXTURE_FORMAT_R32I, ## * (38)
    TEXTURE_FORMAT_R32U, ## * (39)
    TEXTURE_FORMAT_R32F, ## * (40)
    TEXTURE_FORMAT_RG8,  ## * (41)
    TEXTURE_FORMAT_RG8I, ## * (42)
    TEXTURE_FORMAT_RG8U, ## * (43)
    TEXTURE_FORMAT_RG8S, ## * (44)
    TEXTURE_FORMAT_RG16, ## * (45)
    TEXTURE_FORMAT_RG16I, ## * (46)
    TEXTURE_FORMAT_RG16U, ## * (47)
    TEXTURE_FORMAT_RG16F, ## * (48)
    TEXTURE_FORMAT_RG16S, ## * (49)
    TEXTURE_FORMAT_RG32I, ## * (50)
    TEXTURE_FORMAT_RG32U, ## * (51)
    TEXTURE_FORMAT_RG32F, ## * (52)
    TEXTURE_FORMAT_RGB8, ## * (53)
    TEXTURE_FORMAT_RGB8I, ## * (54)
    TEXTURE_FORMAT_RGB8U, ## * (55)
    TEXTURE_FORMAT_RGB8S, ## * (56)
    TEXTURE_FORMAT_RGB9E5F, ## * (57)
    TEXTURE_FORMAT_BGRA8, ## * (58)
    TEXTURE_FORMAT_RGBA8, ## * (59)
    TEXTURE_FORMAT_RGBA8I, ## * (60)
    TEXTURE_FORMAT_RGBA8U, ## * (61)
    TEXTURE_FORMAT_RGBA8S, ## * (62)
    TEXTURE_FORMAT_RGBA16, ## * (63)
    TEXTURE_FORMAT_RGBA16I, ## * (64)
    TEXTURE_FORMAT_RGBA16U, ## * (65)
    TEXTURE_FORMAT_RGBA16F, ## * (66)
    TEXTURE_FORMAT_RGBA16S, ## * (67)
    TEXTURE_FORMAT_RGBA32I, ## * (68)
    TEXTURE_FORMAT_RGBA32U, ## * (69)
    TEXTURE_FORMAT_RGBA32F, ## * (70)
    TEXTURE_FORMAT_R5G6B5, ## * (71)
    TEXTURE_FORMAT_RGBA4, ## * (72)
    TEXTURE_FORMAT_RGB5A1, ## * (73)
    TEXTURE_FORMAT_RGB10A2, ## * (74)
    TEXTURE_FORMAT_RG11B10F, ## * (75)
    TEXTURE_FORMAT_UNKNOWNDEPTH, ## * (76) Depth formats below.
    TEXTURE_FORMAT_D16,  ## * (77)
    TEXTURE_FORMAT_D24,  ## * (78)
    TEXTURE_FORMAT_D24S8, ## * (79)
    TEXTURE_FORMAT_D32,  ## * (80)
    TEXTURE_FORMAT_D16F, ## * (81)
    TEXTURE_FORMAT_D24F, ## * (82)
    TEXTURE_FORMAT_D32F, ## * (83)
    TEXTURE_FORMAT_D0S8, ## * (84)
    TEXTURE_FORMAT_COUNT


## *
##  Uniform type enum.
##
##

type
  uniform_type_t* {.size: sizeof(cint).} = enum
    UNIFORM_TYPE_SAMPLER, ## * ( 0) Sampler.
    UNIFORM_TYPE_END,    ## * ( 1) Reserved, do not use.
    UNIFORM_TYPE_VEC4,   ## * ( 2) 4 floats vector.
    UNIFORM_TYPE_MAT3,   ## * ( 3) 3x3 matrix.
    UNIFORM_TYPE_MAT4,   ## * ( 4) 4x4 matrix.
    UNIFORM_TYPE_COUNT


## *
##  Backbuffer ratio enum.
##
##

type
  backbuffer_ratio_t* {.size: sizeof(cint).} = enum
    BACKBUFFER_RATIO_EQUAL, ## * ( 0) Equal to backbuffer.
    BACKBUFFER_RATIO_HALF, ## * ( 1) One half size of backbuffer.
    BACKBUFFER_RATIO_QUARTER, ## * ( 2) One quarter size of backbuffer.
    BACKBUFFER_RATIO_EIGHTH, ## * ( 3) One eighth size of backbuffer.
    BACKBUFFER_RATIO_SIXTEENTH, ## * ( 4) One sixteenth size of backbuffer.
    BACKBUFFER_RATIO_DOUBLE, ## * ( 5) Double size of backbuffer.
    BACKBUFFER_RATIO_COUNT


## *
##  Occlusion query result.
##
##

type
  occlusion_query_result_t* {.size: sizeof(cint).} = enum
    OCCLUSION_QUERY_RESULT_INVISIBLE, ## * ( 0) Query failed test.
    OCCLUSION_QUERY_RESULT_VISIBLE, ## * ( 1) Query passed test.
    OCCLUSION_QUERY_RESULT_NORESULT, ## * ( 2) Query result is not available yet.
    OCCLUSION_QUERY_RESULT_COUNT


## *
##  Primitive topology.
##
##

type
  topology_t* {.size: sizeof(cint).} = enum
    TOPOLOGY_TRI_LIST,   ## * ( 0) Triangle list.
    TOPOLOGY_TRI_STRIP,  ## * ( 1) Triangle strip.
    TOPOLOGY_LINE_LIST,  ## * ( 2) Line list.
    TOPOLOGY_LINE_STRIP, ## * ( 3) Line strip.
    TOPOLOGY_POINT_LIST, ## * ( 4) Point list.
    TOPOLOGY_COUNT


## *
##  Topology conversion function.
##
##

type
  topology_convert_t* {.size: sizeof(cint).} = enum
    TOPOLOGY_CONVERT_TRI_LIST_FLIP_WINDING, ## * ( 0) Flip winding order of triangle list.
    TOPOLOGY_CONVERT_TRI_STRIP_FLIP_WINDING, ## * ( 1) Flip winding order of trinagle strip.
    TOPOLOGY_CONVERT_TRI_LIST_TO_LINE_LIST, ## * ( 2) Convert triangle list to line list.
    TOPOLOGY_CONVERT_TRI_STRIP_TO_TRI_LIST, ## * ( 3) Convert triangle strip to triangle list.
    TOPOLOGY_CONVERT_LINE_STRIP_TO_LINE_LIST, ## * ( 4) Convert line strip to line list.
    TOPOLOGY_CONVERT_COUNT


## *
##  Topology sort order.
##
##

type
  topology_sort_t* {.size: sizeof(cint).} = enum
    TOPOLOGY_SORT_DIRECTION_FRONT_TO_BACK_MIN, ## * ( 0)
    TOPOLOGY_SORT_DIRECTION_FRONT_TO_BACK_AVG, ## * ( 1)
    TOPOLOGY_SORT_DIRECTION_FRONT_TO_BACK_MAX, ## * ( 2)
    TOPOLOGY_SORT_DIRECTION_BACK_TO_FRONT_MIN, ## * ( 3)
    TOPOLOGY_SORT_DIRECTION_BACK_TO_FRONT_AVG, ## * ( 4)
    TOPOLOGY_SORT_DIRECTION_BACK_TO_FRONT_MAX, ## * ( 5)
    TOPOLOGY_SORT_DISTANCE_FRONT_TO_BACK_MIN, ## * ( 6)
    TOPOLOGY_SORT_DISTANCE_FRONT_TO_BACK_AVG, ## * ( 7)
    TOPOLOGY_SORT_DISTANCE_FRONT_TO_BACK_MAX, ## * ( 8)
    TOPOLOGY_SORT_DISTANCE_BACK_TO_FRONT_MIN, ## * ( 9)
    TOPOLOGY_SORT_DISTANCE_BACK_TO_FRONT_AVG, ## * (10)
    TOPOLOGY_SORT_DISTANCE_BACK_TO_FRONT_MAX, ## * (11)
    TOPOLOGY_SORT_COUNT


## *
##  View mode sets draw call sort order.
##
##

type
  view_mode_t* {.size: sizeof(cint).} = enum
    VIEW_MODE_DEFAULT,   ## * ( 0) Default sort order.
    VIEW_MODE_SEQUENTIAL, ## * ( 1) Sort in the same order in which submit calls were called.
    VIEW_MODE_DEPTH_ASCENDING, ## * ( 2) Sort draw call depth in ascending order.
    VIEW_MODE_DEPTH_DESCENDING, ## * ( 3) Sort draw call depth in descending order.
    VIEW_MODE_COUNT


## *
##  Render frame enum.
##
##

type
  render_frame_t* {.size: sizeof(cint).} = enum
    RENDER_FRAME_NO_CONTEXT, ## * ( 0) Renderer context is not created yet.
    RENDER_FRAME_RENDER, ## * ( 1) Renderer context is created and rendering.
    RENDER_FRAME_TIMEOUT, ## * ( 2) Renderer context wait for main thread signal timed out without rendering.
    RENDER_FRAME_EXITING, ## * ( 3) Renderer context is getting destroyed.
    RENDER_FRAME_COUNT



type
  view_id_t* = uint16


type
  allocator_interface_t* {.bycopy.} = object
    vtbl*: ptr allocator_vtbl_t

  allocator_vtbl_t* {.bycopy.} = object
    realloc*: proc (this: ptr allocator_interface_t; `ptr`: pointer; size: csize;
                  align: csize; file: cstring; line: uint32): pointer {.cdecl.}

type
  callback_interface_t* {.bycopy.} = object
    vtbl*: ptr callback_vtbl_t

  callback_vtbl_t* {.bycopy.} = object
    fatal*: proc (this: ptr callback_interface_t; filePath: cstring;
                line: uint16; code: fatal_t; str: cstring) {.cdecl.}
    trace_vargs*: proc (this: ptr callback_interface_t; filePath: cstring;
                      line: uint16; format: cstring; argList: va_list) {.cdecl.}
    profiler_begin*: proc (this: ptr callback_interface_t; name: cstring;
                         abgr: uint32; filePath: cstring; line: uint16) {.cdecl.}
    profiler_begin_literal*: proc (this: ptr callback_interface_t;
                                 name: cstring; abgr: uint32;
                                 filePath: cstring; line: uint16) {.cdecl.}
    profiler_end*: proc (this: ptr callback_interface_t) {.cdecl.}
    cache_read_size*: proc (this: ptr callback_interface_t; id: uint64): uint32 {.
        cdecl.}
    cache_read*: proc (this: ptr callback_interface_t; id: uint64;
                     data: pointer; size: uint32): bool {.cdecl.}
    cache_write*: proc (this: ptr callback_interface_t; id: uint64;
                      data: pointer; size: uint32) {.cdecl.}
    screen_shot*: proc (this: ptr callback_interface_t; filePath: cstring;
                      width: uint32; height: uint32; pitch: uint32;
                      data: pointer; size: uint32; yflip: bool) {.cdecl.}
    capture_begin*: proc (this: ptr callback_interface_t; width: uint32;
                        height: uint32; pitch: uint32;
                        format: texture_format_t; yflip: bool) {.cdecl.}
    capture_end*: proc (this: ptr callback_interface_t) {.cdecl.}
    capture_frame*: proc (this: ptr callback_interface_t; data: pointer;
                        size: uint32) {.cdecl.}

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


## *
##  Memory release callback.
##
##  @param[in] _ptr Pointer to allocated data.
##  @param[in] _userData User defined data if needed.
##
##

type
  release_fn_t* = proc (ptr: pointer; userData: pointer) {.cdecl.}

## *
##  GPU info.
##
##

type
  caps_gpu_t* {.bycopy.} = object
    vendorId*: uint16        ## * Vendor PCI id. See `PCI_ID_*`.
    deviceId*: uint16        ## * Device id.


## *
##  Renderer capabilities limits.
##
##

type
  caps_limits_t* {.bycopy.} = object
    maxDrawCalls*: uint32    ## * Maximum number of draw calls.
    maxBlits*: uint32        ## * Maximum number of blit calls.
    maxTextureSize*: uint32  ## * Maximum texture size.
    maxTextureLayers*: uint32 ## * Maximum texture layers.
    maxViews*: uint32        ## * Maximum number of views.
    maxFrameBuffers*: uint32 ## * Maximum number of frame buffer handles.
    maxFBAttachments*: uint32 ## * Maximum number of frame buffer attachments.
    maxPrograms*: uint32     ## * Maximum number of program handles.
    maxShaders*: uint32      ## * Maximum number of shader handles.
    maxTextures*: uint32     ## * Maximum number of texture handles.
    maxTextureSamplers*: uint32 ## * Maximum number of texture samplers.
    maxComputeBindings*: uint32 ## * Maximum number of compute bindings.
    maxVertexDecls*: uint32  ## * Maximum number of vertex format declarations.
    maxVertexStreams*: uint32 ## * Maximum number of vertex streams.
    maxIndexBuffers*: uint32 ## * Maximum number of index buffer handles.
    maxVertexBuffers*: uint32 ## * Maximum number of vertex buffer handles.
    maxDynamicIndexBuffers*: uint32 ## * Maximum number of dynamic index buffer handles.
    maxDynamicVertexBuffers*: uint32 ## * Maximum number of dynamic vertex buffer handles.
    maxUniforms*: uint32     ## * Maximum number of uniform handles.
    maxOcclusionQueries*: uint32 ## * Maximum number of occlusion query handles.
    maxEncoders*: uint32     ## * Maximum number of encoder threads.
    transientVbSize*: uint32 ## * Maximum transient vertex buffer size.
    transientIbSize*: uint32 ## * Maximum transient index buffer size.


## *
##  Renderer capabilities.
##
##

type
  caps_t* {.bycopy.} = object
    rendererType*: renderer_type_t ## * Renderer backend type. See: `bgfx::RendererType`
                                      ## *
                                      ##  Supported functionality.
                                      ##    @attention See CAPS_* flags at
                                      ## https://bkaradzic.github.io/bgfx/bgfx.html#available-caps
                                      ##
    supported*: uint64
    vendorId*: uint16        ## * Selected GPU vendor PCI id.
    deviceId*: uint16        ## * Selected GPU device id.
    homogeneousDepth*: bool    ## * True when NDC depth is in [-1, 1] range, otherwise its [0, 1].
    originBottomLeft*: bool    ## * True when NDC origin is at bottom left.
    numGPUs*: uint8_t          ## * Number of enumerated GPUs.
    gpu*: array[4, caps_gpu_t] ## * Enumerated GPUs.
    limits*: caps_limits_t ## *
                              ##  Supported texture format capabilities flags:
                              ##    - `CAPS_FORMAT_TEXTURE_NONE` - Texture format is not supported.
                              ##    - `CAPS_FORMAT_TEXTURE_2D` - Texture format is supported.
                              ##    - `CAPS_FORMAT_TEXTURE_2D_SRGB` - Texture as sRGB format is supported.
                              ##    - `CAPS_FORMAT_TEXTURE_2D_EMULATED` - Texture format is emulated.
                              ##    - `CAPS_FORMAT_TEXTURE_3D` - Texture format is supported.
                              ##    - `CAPS_FORMAT_TEXTURE_3D_SRGB` - Texture as sRGB format is supported.
                              ##    - `CAPS_FORMAT_TEXTURE_3D_EMULATED` - Texture format is emulated.
                              ##    - `CAPS_FORMAT_TEXTURE_CUBE` - Texture format is supported.
                              ##    - `CAPS_FORMAT_TEXTURE_CUBE_SRGB` - Texture as sRGB format is supported.
                              ##    - `CAPS_FORMAT_TEXTURE_CUBE_EMULATED` - Texture format is emulated.
                              ##    - `CAPS_FORMAT_TEXTURE_VERTEX` - Texture format can be used from vertex shader.
                              ##    - `CAPS_FORMAT_TEXTURE_IMAGE` - Texture format can be used as image from compute
                              ##      shader.
                              ##    - `CAPS_FORMAT_TEXTURE_FRAMEBUFFER` - Texture format can be used as frame
                              ##      buffer.
                              ##    - `CAPS_FORMAT_TEXTURE_FRAMEBUFFER_MSAA` - Texture format can be used as MSAA
                              ##      frame buffer.
                              ##    - `CAPS_FORMAT_TEXTURE_MSAA` - Texture can be sampled as MSAA.
                              ##    - `CAPS_FORMAT_TEXTURE_MIP_AUTOGEN` - Texture format supports auto-generated
                              ##      mips.
                              ##
    formats*: array[TEXTURE_FORMAT_COUNT, uint16]


## *
##  Internal data.
##
##

type
  internal_data_t* {.bycopy.} = object
    caps*: ptr caps_t      ## * Renderer capabilities.
    context*: pointer          ## * GL context, or D3D device.


## *
##  Platform data.
##
##

type
  platform_data_t* {.bycopy.} = object
    ndt*: pointer              ## * Native display type.
    nwh*: pointer              ## * Native window handle.
    context*: pointer          ## * GL context, or D3D device.
    backBuffer*: pointer       ## * GL backbuffer, or D3D render target view.
    backBufferDS*: pointer     ## * Backbuffer depth/stencil.


## *
##  Backbuffer resolution and reset parameters.
##
##

type
  resolution_t* {.bycopy.} = object
    format*: texture_format_t ## * Backbuffer format.
    width*: uint32           ## * Backbuffer width.
    height*: uint32          ## * Backbuffer height.
    reset*: uint32           ## * Reset parameters.
    numBackBuffers*: uint8_t   ## * Number of back buffers.
    maxFrameLatency*: uint8_t  ## * Maximum frame latency.

  init_limits_t* {.bycopy.} = object
    maxEncoders*: uint16     ## * Maximum number of encoder threads.
    transientVbSize*: uint32 ## * Maximum transient vertex buffer size.
    transientIbSize*: uint32 ## * Maximum transient index buffer size.


## *
##  Initialization parameters used by `bgfx::init`.
##
##

type
  init_t* {.bycopy.} = object
    `type`*: renderer_type_t ## *
                                ##  Select rendering backend. When set to RendererType::Count
                                ##  a default rendering backend will be selected appropriate to the platform.
                                ##  See: `bgfx::RendererType`
                                ##
    ## *
    ##  Vendor PCI id. If set to `PCI_ID_NONE` it will select the first
    ##  device.
    ##    - `PCI_ID_NONE` - Autoselect adapter.
    ##    - `PCI_ID_SOFTWARE_RASTERIZER` - Software rasterizer.
    ##    - `PCI_ID_AMD` - AMD adapter.
    ##    - `PCI_ID_INTEL` - Intel adapter.
    ##    - `PCI_ID_NVIDIA` - nVidia adapter.
    ##
    vendorId*: uint16 ## *
                      ##  Device id. If set to 0 it will select first device, or device with
                      ##  matching id.
                      ##
    deviceId*: uint16
    debug*: bool               ## * Enable device for debuging.
    profile*: bool             ## * Enable device for profiling.
    platformData*: platform_data_t ## * Platform data.
    resolution*: resolution_t ## * Backbuffer resolution and reset parameters. See: `bgfx::Resolution`.
    limits*: init_limits_t ## *
                              ##  Provide application specific callback interface.
                              ##  See: `bgfx::CallbackI`
                              ##
    callback*: ptr callback_interface_t ## *
                                          ##  Custom allocator. When a custom allocator is not
                                          ##  specified, bgfx uses the CRT allocator. Bgfx assumes
                                          ##  custom allocator is thread safe.
                                          ##
    allocator*: ptr allocator_interface_t


## *
##  Memory must be obtained by calling `bgfx::alloc`, `bgfx::copy`, or `bgfx::makeRef`.
##  @attention It is illegal to create this structure on stack and pass it to any bgfx API.
##
##

type
  memory_t* {.bycopy.} = object
    data*: ptr uint8_t          ## * Pointer to data.
    size*: uint32            ## * Data size.


## *
##  Transient index buffer.
##
##

type
  transient_index_buffer_t* {.bycopy.} = object
    data*: ptr uint8_t          ## * Pointer to data.
    size*: uint32            ## * Data size.
    startIndex*: uint32      ## * First index.
    handle*: index_buffer_handle_t ## * Index buffer handle.


## *
##  Transient vertex buffer.
##
##

type
  transient_vertex_buffer_t* {.bycopy.} = object
    data*: ptr uint8_t          ## * Pointer to data.
    size*: uint32            ## * Data size.
    startVertex*: uint32     ## * First vertex.
    stride*: uint16          ## * Vertex stride.
    handle*: vertex_buffer_handle_t ## * Vertex buffer handle.
    decl*: vertex_decl_handle_t ## * Vertex declaration handle.


## *
##  Instance data buffer info.
##
##

type
  instance_data_buffer_t* {.bycopy.} = object
    data*: ptr uint8_t          ## * Pointer to data.
    size*: uint32            ## * Data size.
    offset*: uint32          ## * Offset in vertex buffer.
    num*: uint32             ## * Number of instances.
    stride*: uint16          ## * Vertex buffer stride.
    handle*: vertex_buffer_handle_t ## * Vertex buffer object handle.


## *
##  Texture info.
##
##

type
  texture_info_t* {.bycopy.} = object
    format*: texture_format_t ## * Texture format.
    storageSize*: uint32     ## * Total amount of bytes required to store texture.
    width*: uint16           ## * Texture width.
    height*: uint16          ## * Texture height.
    depth*: uint16           ## * Texture depth.
    numLayers*: uint16       ## * Number of layers in texture array.
    numMips*: uint8_t          ## * Number of MIP maps.
    bitsPerPixel*: uint8_t     ## * Format bits per pixel.
    cubeMap*: bool             ## * Texture is cubemap.


## *
##  Uniform info.
##
##

type
  uniform_info_t* {.bycopy.} = object
    name*: array[256, char]     ## * Uniform name.
    `type`*: uniform_type_t ## * Uniform type.
    num*: uint16             ## * Number of elements in array.


## *
##  Frame buffer texture attachment info.
##
##

type
  attachment_t* {.bycopy.} = object
    access*: access_t     ## * Attachement access. See `Access::Enum`.
    handle*: texture_handle_t ## * Render target texture handle.
    mip*: uint16             ## * Mip level.
    layer*: uint16           ## * Cubemap side or depth layer/slice.
    resolve*: uint8_t          ## * Resolve flags. See: `RESOLVE_*`


## *
##  Transform data.
##
##

type
  transform_t* {.bycopy.} = object
    data*: ptr cfloat           ## * Pointer to first 4x4 matrix.
    num*: uint16             ## * Number of matrices.


## *
##  View stats.
##
##

type
  view_stats_t* {.bycopy.} = object
    name*: array[256, char]     ## * View name.
    view*: view_id_t      ## * View id.
    cpuTimeElapsed*: int64_t   ## * CPU (submit) time elapsed.
    gpuTimeElapsed*: int64_t   ## * GPU time elapsed.


## *
##  Encoder stats.
##
##

type
  encoder_stats_t* {.bycopy.} = object
    cpuTimeBegin*: int64_t     ## * Encoder thread CPU submit begin time.
    cpuTimeEnd*: int64_t       ## * Encoder thread CPU submit end time.


## *
##  Renderer statistics data.
##  @remarks All time values are high-resolution timestamps, while
##  time frequencies define timestamps-per-second for that hardware.
##
##

type
  stats_t* {.bycopy.} = object
    cpuTimeFrame*: int64_t     ## * CPU time between two `bgfx::frame` calls.
    cpuTimeBegin*: int64_t     ## * Render thread CPU submit begin time.
    cpuTimeEnd*: int64_t       ## * Render thread CPU submit end time.
    cpuTimerFreq*: int64_t     ## * CPU timer frequency. Timestamps-per-second
    gpuTimeBegin*: int64_t     ## * GPU frame begin time.
    gpuTimeEnd*: int64_t       ## * GPU frame end time.
    gpuTimerFreq*: int64_t     ## * GPU timer frequency.
    waitRender*: int64_t       ## * Time spent waiting for render backend thread to finish issuing draw commands to underlying graphics API.
    waitSubmit*: int64_t       ## * Time spent waiting for submit thread to advance to next frame.
    numDraw*: uint32         ## * Number of draw calls submitted.
    numCompute*: uint32      ## * Number of compute calls submitted.
    numBlit*: uint32         ## * Number of blit calls submitted.
    maxGpuLatency*: uint32   ## * GPU driver latency.
    numDynamicIndexBuffers*: uint16 ## * Number of used dynamic index buffers.
    numDynamicVertexBuffers*: uint16 ## * Number of used dynamic vertex buffers.
    numFrameBuffers*: uint16 ## * Number of used frame buffers.
    numIndexBuffers*: uint16 ## * Number of used index buffers.
    numOcclusionQueries*: uint16 ## * Number of used occlusion queries.
    numPrograms*: uint16     ## * Number of used programs.
    numShaders*: uint16      ## * Number of used shaders.
    numTextures*: uint16     ## * Number of used textures.
    numUniforms*: uint16     ## * Number of used uniforms.
    numVertexBuffers*: uint16 ## * Number of used vertex buffers.
    numVertexDecls*: uint16  ## * Number of used vertex declarations.
    textureMemoryUsed*: int64_t ## * Estimate of texture memory used.
    rtMemoryUsed*: int64_t     ## * Estimate of render target memory used.
    transientVbUsed*: int32_t  ## * Amount of transient vertex buffer used.
    transientIbUsed*: int32_t  ## * Amount of transient index buffer used.
    numPrims*: array[TOPOLOGY_COUNT, uint32] ## * Number of primitives rendered.
    gpuMemoryMax*: int64_t     ## * Maximum available GPU memory for application.
    gpuMemoryUsed*: int64_t    ## * Amount of GPU memory used by the application.
    width*: uint16           ## * Backbuffer width in pixels.
    height*: uint16          ## * Backbuffer height in pixels.
    textWidth*: uint16       ## * Debug text width in characters.
    textHeight*: uint16      ## * Debug text height in characters.
    numViews*: uint16        ## * Number of view stats.
    viewStats*: ptr view_stats_t ## * Array of View stats.
    numEncoders*: uint8_t      ## * Number of encoders used during frame.
    encoderStats*: ptr encoder_stats_t ## * Array of encoder stats.


## *
##  Vertex declaration.
##
##

type
  vertex_decl_t* {.bycopy.} = object
    hash*: uint32            ## * Hash.
    stride*: uint16          ## * Stride.
    offset*: array[ATTRIB_COUNT, uint16] ## * Attribute offsets.
    attributes*: array[ATTRIB_COUNT, uint16] ## * Used attributes.


## *
##  Encoders are used for submitting draw calls from multiple threads. Only one encoder
##  per thread should be used. Use `bgfx::begin()` to obtain an encoder for a thread.
##
##

type
  encoder_s* {.bycopy.} = object

  encoder_t* = encoder_s

## *
##  Init attachment.
##
##  @param[in] _handle Render target texture handle.
##  @param[in] _access Access. See `Access::Enum`.
##  @param[in] _layer Cubemap side or depth layer/slice.
##  @param[in] _mip Mip level.
##  @param[in] _resolve Resolve flags. See: `RESOLVE_*`
##
##

proc attachment_init*(this: ptr attachment_t;
                          handle: texture_handle_t; access: access_t;
                          layer: uint16; mip: uint16; resolve: uint8_t) {.
    cdecl, importc: "bgfx_attachment_init", dynlib: lib.}
## *
##  Start VertexDecl.
##
##  @param[in] _rendererType
##
##

proc vertex_decl_begin*(this: ptr vertex_decl_t;
                            rendererType: renderer_type_t): ptr vertex_decl_t {.
    cdecl, importc: "bgfx_vertex_decl_begin", dynlib: lib.}
## *
##  Add attribute to VertexDecl.
##  @remarks Must be called between begin/end.
##
##  @param[in] _attrib Attribute semantics. See: `bgfx::Attrib`
##  @param[in] _num Number of elements 1, 2, 3 or 4.
##  @param[in] _type Element type.
##  @param[in] _normalized When using fixed point AttribType (f.e. Uint8)
##   value will be normalized for vertex shader usage. When normalized
##   is set to true, AttribType::Uint8 value in range 0-255 will be
##   in range 0.0-1.0 in vertex shader.
##  @param[in] _asInt Packaging rule for vertexPack, vertexUnpack, and
##   vertexConvert for AttribType::Uint8 and AttribType::Int16.
##   Unpacking code must be implemented inside vertex shader.
##
##

proc vertex_decl_add*(this: ptr vertex_decl_t; attrib: attrib_t;
                          num: uint8_t; type: attrib_type_t;
                          normalized: bool; asInt: bool): ptr vertex_decl_t {.
    cdecl, importc: "bgfx_vertex_decl_add", dynlib: lib.}
## *
##  Decode attribute.
##
##  @param[in] _attrib Attribute semantics. See: `bgfx::Attrib`
##  @param[out] _num Number of elements.
##  @param[out] _type Element type.
##  @param[out] _normalized Attribute is normalized.
##  @param[out] _asInt Attribute is packed as int.
##
##

proc vertex_decl_decode*(this: ptr vertex_decl_t; attrib: attrib_t;
                             num: ptr uint8_t; type: ptr attrib_type_t;
                             normalized: ptr bool; asInt: ptr bool) {.cdecl,
    importc: "bgfx_vertex_decl_decode", dynlib: lib.}
## *
##  Returns true if VertexDecl contains attribute.
##
##  @param[in] _attrib Attribute semantics. See: `bgfx::Attrib`
##
##

proc vertex_decl_has*(this: ptr vertex_decl_t; attrib: attrib_t): bool {.
    cdecl, importc: "bgfx_vertex_decl_has", dynlib: lib.}
## *
##  Skip `_num` bytes in vertex stream.
##
##  @param[in] _num
##
##

proc vertex_decl_skip*(this: ptr vertex_decl_t; num: uint8_t): ptr vertex_decl_t {.
    cdecl, importc: "bgfx_vertex_decl_skip", dynlib: lib.}
## *
##  End VertexDecl.
##
##

proc vertex_decl_end*(this: ptr vertex_decl_t) {.cdecl,
    importc: "bgfx_vertex_decl_end", dynlib: lib.}
## *
##  Pack vertex attribute into vertex stream format.
##
##  @param[in] _input Value to be packed into vertex stream.
##  @param[in] _inputNormalized `true` if input value is already normalized.
##  @param[in] _attr Attribute to pack.
##  @param[in] _decl Vertex stream declaration.
##  @param[in] _data Destination vertex stream where data will be packed.
##  @param[in] _index Vertex index that will be modified.
##
##

proc vertex_pack*(input: array[4, cfloat]; inputNormalized: bool;
                      attr: attrib_t; decl: ptr vertex_decl_t;
                      data: pointer; index: uint32) {.cdecl,
    importc: "bgfx_vertex_pack", dynlib: lib.}
## *
##  Unpack vertex attribute from vertex stream format.
##
##  @param[out] _output Result of unpacking.
##  @param[in] _attr Attribute to unpack.
##  @param[in] _decl Vertex stream declaration.
##  @param[in] _data Source vertex stream from where data will be unpacked.
##  @param[in] _index Vertex index that will be unpacked.
##
##

proc vertex_unpack*(output: array[4, cfloat]; attr: attrib_t;
                        decl: ptr vertex_decl_t; data: pointer;
                        index: uint32) {.cdecl, importc: "bgfx_vertex_unpack",
    dynlib: lib.}
## *
##  Converts vertex stream data from one vertex stream format to another.
##
##  @param[in] _dstDecl Destination vertex stream declaration.
##  @param[in] _dstData Destination vertex stream.
##  @param[in] _srcDecl Source vertex stream declaration.
##  @param[in] _srcData Source vertex stream data.
##  @param[in] _num Number of vertices to convert from source to destination.
##
##

proc vertex_convert*(dstDecl: ptr vertex_decl_t; dstData: pointer;
                         srcDecl: ptr vertex_decl_t; srcData: pointer;
                         num: uint32) {.cdecl, importc: "bgfx_vertex_convert",
    dynlib: lib.}
## *
##  Weld vertices.
##
##  @param[in] _output Welded vertices remapping table. The size of buffer
##   must be the same as number of vertices.
##  @param[in] _decl Vertex stream declaration.
##  @param[in] _data Vertex stream.
##  @param[in] _num Number of vertices in vertex stream.
##  @param[in] _epsilon Error tolerance for vertex position comparison.
##
##  @returns Number of unique vertices after vertex welding.
##
##

proc weld_vertices*(output: ptr uint16; decl: ptr vertex_decl_t;
                        data: pointer; num: uint16; epsilon: cfloat): uint16 {.
    cdecl, importc: "bgfx_weld_vertices", dynlib: lib.}
## *
##  Convert index buffer for use with different primitive topologies.
##
##  @param[in] _conversion Conversion type, see `TopologyConvert::Enum`.
##  @param[out] _dst Destination index buffer. If this argument is NULL
##   function will return number of indices after conversion.
##  @param[in] _dstSize Destination index buffer in bytes. It must be
##   large enough to contain output indices. If destination size is
##   insufficient index buffer will be truncated.
##  @param[in] _indices Source indices.
##  @param[in] _numIndices Number of input indices.
##  @param[in] _index32 Set to `true` if input indices are 32-bit.
##
##  @returns Number of output indices after conversion.
##
##

proc topology_convert*(conversion: topology_convert_t; dst: pointer;
                           dstSize: uint32; indices: pointer;
                           numIndices: uint32; index32: bool): uint32 {.cdecl,
    importc: "bgfx_topology_convert", dynlib: lib.}
## *
##  Sort indices.
##
##  @param[in] _sort Sort order, see `TopologySort::Enum`.
##  @param[out] _dst Destination index buffer.
##  @param[in] _dstSize Destination index buffer in bytes. It must be
##   large enough to contain output indices. If destination size is
##   insufficient index buffer will be truncated.
##  @param[in] _dir Direction (vector must be normalized).
##  @param[in] _pos Position.
##  @param[in] _vertices Pointer to first vertex represented as
##   float x, y, z. Must contain at least number of vertices
##   referencende by index buffer.
##  @param[in] _stride Vertex stride.
##  @param[in] _indices Source indices.
##  @param[in] _numIndices Number of input indices.
##  @param[in] _index32 Set to `true` if input indices are 32-bit.
##
##

proc topology_sort_tri_list*(sort: topology_sort_t; dst: pointer;
                                 dstSize: uint32; dir: array[3, cfloat];
                                 pos: array[3, cfloat]; vertices: pointer;
                                 stride: uint32; indices: pointer;
                                 numIndices: uint32; index32: bool) {.cdecl,
    importc: "bgfx_topology_sort_tri_list", dynlib: lib.}
## *
##  Returns supported backend API renderers.
##
##  @param[in] _max Maximum number of elements in _enum array.
##  @param[inout] _enum Array where supported renderers will be written.
##
##  @returns Number of supported renderers.
##
##

proc get_supported_renderers*(max: uint8_t; enum: ptr renderer_type_t): uint8_t {.
    cdecl, importc: "bgfx_get_supported_renderers", dynlib: lib.}
## *
##  Returns name of renderer.
##
##  @param[in] _type Renderer backend type. See: `bgfx::RendererType`
##
##  @returns Name of renderer.
##
##

proc get_renderer_name*(type: renderer_type_t): cstring {.cdecl,
    importc: "bgfx_get_renderer_name", dynlib: lib.}
proc init_ctor*(init: ptr init_t) {.cdecl, importc: "bgfx_init_ctor",
    dynlib: lib.}
## *
##  Initialize bgfx library.
##
##  @param[in] _init Initialization parameters. See: `bgfx::Init` for more info.
##
##  @returns `true` if initialization was successful.
##
##

proc init*(init: ptr init_t): bool {.cdecl, importc: "bgfx_init", dynlib: lib.}
## *
##  Shutdown bgfx library.
##
##

proc shutdown*() {.cdecl, importc: "bgfx_shutdown", dynlib: lib.}
## *
##  Reset graphic settings and back-buffer size.
##  @attention This call doesn't actually change window size, it just
##    resizes back-buffer. Windowing code has to change window size.
##
##  @param[in] _width Back-buffer width.
##  @param[in] _height Back-buffer height.
##  @param[in] _flags See: `RESET_*` for more info.
##     - `RESET_NONE` - No reset flags.
##     - `RESET_FULLSCREEN` - Not supported yet.
##     - `RESET_MSAA_X[2/4/8/16]` - Enable 2, 4, 8 or 16 x MSAA.
##     - `RESET_VSYNC` - Enable V-Sync.
##     - `RESET_MAXANISOTROPY` - Turn on/off max anisotropy.
##     - `RESET_CAPTURE` - Begin screen capture.
##     - `RESET_FLUSH_AFTER_RENDER` - Flush rendering after submitting to GPU.
##     - `RESET_FLIP_AFTER_RENDER` - This flag  specifies where flip
##       occurs. Default behavior is that flip occurs before rendering new
##       frame. This flag only has effect when `CONFIG_MULTITHREADED=0`.
##     - `RESET_SRGB_BACKBUFFER` - Enable sRGB backbuffer.
##  @param[in] _format Texture format. See: `TextureFormat::Enum`.
##
##

proc reset*(width: uint32; height: uint32; flags: uint32;
                format: texture_format_t) {.cdecl, importc: "bgfx_reset",
    dynlib: lib.}
## *
##  Advance to next frame. When using multithreaded renderer, this call
##  just swaps internal buffers, kicks render thread, and returns. In
##  singlethreaded renderer this call does frame rendering.
##
##  @param[in] _capture Capture frame with graphics debugger.
##
##  @returns Current frame number. This might be used in conjunction with
##   double/multi buffering data outside the library and passing it to
##   library via `bgfx::makeRef` calls.
##
##

proc frame*(capture: bool): uint32 {.cdecl, importc: "bgfx_frame", dynlib: lib.}
## *
##  Returns current renderer backend API type.
##  @remarks
##    Library must be initialized.
##
##

proc get_renderer_type*(): renderer_type_t {.cdecl,
    importc: "bgfx_get_renderer_type", dynlib: lib.}
## *
##  Returns renderer capabilities.
##  @remarks
##    Library must be initialized.
##
##

proc get_caps*(): ptr caps_t {.cdecl, importc: "bgfx_get_caps", dynlib: lib.}
## *
##  Returns performance counters.
##  @attention Pointer returned is valid until `bgfx::frame` is called.
##
##

proc get_stats*(): ptr stats_t {.cdecl, importc: "bgfx_get_stats",
                                       dynlib: lib.}
## *
##  Allocate buffer to pass to bgfx calls. Data will be freed inside bgfx.
##
##  @param[in] _size Size to allocate.
##
##  @returns Allocated memory.
##
##

proc alloc*(size: uint32): ptr memory_t {.cdecl, importc: "bgfx_alloc",
    dynlib: lib.}
## *
##  Allocate buffer and copy data into it. Data will be freed inside bgfx.
##
##  @param[in] _data Pointer to data to be copied.
##  @param[in] _size Size of data to be copied.
##
##  @returns Allocated memory.
##
##

proc copy*(data: pointer; size: uint32): ptr memory_t {.cdecl,
    importc: "bgfx_copy", dynlib: lib.}
## *
##  Make reference to data to pass to bgfx. Unlike `bgfx::alloc`, this call
##  doesn't allocate memory for data. It just copies the _data pointer. You
##  can pass `ReleaseFn` function pointer to release this memory after it's
##  consumed, otherwise you must make sure _data is available for at least 2
##  `bgfx::frame` calls. `ReleaseFn` function must be able to be called
##  from any thread.
##  @attention Data passed must be available for at least 2 `bgfx::frame` calls.
##
##  @param[in] _data Pointer to data.
##  @param[in] _size Size of data.
##
##  @returns Referenced memory.
##
##

proc make_ref*(data: pointer; size: uint32): ptr memory_t {.cdecl,
    importc: "bgfx_make_ref", dynlib: lib.}
## *
##  Make reference to data to pass to bgfx. Unlike `bgfx::alloc`, this call
##  doesn't allocate memory for data. It just copies the _data pointer. You
##  can pass `ReleaseFn` function pointer to release this memory after it's
##  consumed, otherwise you must make sure _data is available for at least 2
##  `bgfx::frame` calls. `ReleaseFn` function must be able to be called
##  from any thread.
##  @attention Data passed must be available for at least 2 `bgfx::frame` calls.
##
##  @param[in] _data Pointer to data.
##  @param[in] _size Size of data.
##  @param[in] _releaseFn Callback function to release memory after use.
##  @param[in] _userData User data to be passed to callback function.
##
##  @returns Referenced memory.
##
##

proc make_ref_release*(data: pointer; size: uint32;
                           releaseFn: release_fn_t; userData: pointer): ptr memory_t {.
    cdecl, importc: "bgfx_make_ref_release", dynlib: lib.}
## *
##  Set debug flags.
##
##  @param[in] _debug Available flags:
##     - `DEBUG_IFH` - Infinitely fast hardware. When this flag is set
##       all rendering calls will be skipped. This is useful when profiling
##       to quickly assess potential bottlenecks between CPU and GPU.
##     - `DEBUG_PROFILER` - Enable profiler.
##     - `DEBUG_STATS` - Display internal statistics.
##     - `DEBUG_TEXT` - Display debug text.
##     - `DEBUG_WIREFRAME` - Wireframe rendering. All rendering
##       primitives will be rendered as lines.
##
##

proc set_debug*(debug: uint32) {.cdecl, importc: "bgfx_set_debug", dynlib: lib.}
## *
##  Clear internal debug text buffer.
##
##  @param[in] _attr Background color.
##  @param[in] _small Default or 8x8 font.
##
##

proc dbg_text_clear*(attr: uint8_t; small: bool) {.cdecl,
    importc: "bgfx_dbg_text_clear", dynlib: lib.}
## *
##  Print formatted data to internal debug text character-buffer (VGA-compatible text mode).
##
##  @param[in] _x Position x from the left corner of the window.
##  @param[in] _y Position y from the top corner of the window.
##  @param[in] _attr Color palette. Where top 4-bits represent index of background, and bottom
##   4-bits represent foreground color from standard VGA text palette (ANSI escape codes).
##  @param[in] _format `printf` style format.
##  @param[in]
##
##

proc dbg_text_printf*(x: uint16; y: uint16; attr: uint8_t; format: cstring) {.
    varargs, cdecl, importc: "bgfx_dbg_text_printf", dynlib: lib.}
## *
##  Print formatted data from variable argument list to internal debug text character-buffer (VGA-compatible text mode).
##
##  @param[in] _x Position x from the left corner of the window.
##  @param[in] _y Position y from the top corner of the window.
##  @param[in] _attr Color palette. Where top 4-bits represent index of background, and bottom
##   4-bits represent foreground color from standard VGA text palette (ANSI escape codes).
##  @param[in] _format `printf` style format.
##  @param[in] _argList Variable arguments list for format string.
##
##

proc dbg_text_vprintf*(x: uint16; y: uint16; attr: uint8_t;
                           format: cstring; argList: va_list) {.cdecl,
    importc: "bgfx_dbg_text_vprintf", dynlib: lib.}
## *
##  Draw image into internal debug text buffer.
##
##  @param[in] _x Position x from the left corner of the window.
##  @param[in] _y Position y from the top corner of the window.
##  @param[in] _width Image width.
##  @param[in] _height Image height.
##  @param[in] _data Raw image data (character/attribute raw encoding).
##  @param[in] _pitch Image pitch in bytes.
##
##

proc dbg_text_image*(x: uint16; y: uint16; width: uint16;
                         height: uint16; data: pointer; pitch: uint16) {.cdecl,
    importc: "bgfx_dbg_text_image", dynlib: lib.}
## *
##  Create static index buffer.
##
##  @param[in] _mem Index buffer data.
##  @param[in] _flags Buffer creation flags.
##     - `BUFFER_NONE` - No flags.
##     - `BUFFER_COMPUTE_READ` - Buffer will be read from by compute shader.
##     - `BUFFER_COMPUTE_WRITE` - Buffer will be written into by compute shader. When buffer
##         is created with `BUFFER_COMPUTE_WRITE` flag it cannot be updated from CPU.
##     - `BUFFER_COMPUTE_READ_WRITE` - Buffer will be used for read/write by compute shader.
##     - `BUFFER_ALLOW_RESIZE` - Buffer will resize on buffer update if a different amount of
##         data is passed. If this flag is not specified, and more data is passed on update, the buffer
##         will be trimmed to fit the existing buffer size. This flag has effect only on dynamic
##         buffers.
##     - `BUFFER_INDEX32` - Buffer is using 32-bit indices. This flag has effect only on
##         index buffers.
##
##

proc create_index_buffer*(mem: ptr memory_t; flags: uint16): index_buffer_handle_t {.
    cdecl, importc: "bgfx_create_index_buffer", dynlib: lib.}
## *
##  Set static index buffer debug name.
##
##  @param[in] _handle Static index buffer handle.
##  @param[in] _name Static index buffer name.
##  @param[in] _len Static index buffer name length (if length is INT32_MAX, it's expected
##   that _name is zero terminated string.
##
##

proc set_index_buffer_name*(handle: index_buffer_handle_t;
                                name: cstring; len: int32_t) {.cdecl,
    importc: "bgfx_set_index_buffer_name", dynlib: lib.}
## *
##  Destroy static index buffer.
##
##  @param[in] _handle Static index buffer handle.
##
##

proc destroy_index_buffer*(handle: index_buffer_handle_t) {.cdecl,
    importc: "bgfx_destroy_index_buffer", dynlib: lib.}
## *
##  Create static vertex buffer.
##
##  @param[in] _mem Vertex buffer data.
##  @param[in] _decl Vertex declaration.
##  @param[in] _flags Buffer creation flags.
##    - `BUFFER_NONE` - No flags.
##    - `BUFFER_COMPUTE_READ` - Buffer will be read from by compute shader.
##    - `BUFFER_COMPUTE_WRITE` - Buffer will be written into by compute shader. When buffer
##        is created with `BUFFER_COMPUTE_WRITE` flag it cannot be updated from CPU.
##    - `BUFFER_COMPUTE_READ_WRITE` - Buffer will be used for read/write by compute shader.
##    - `BUFFER_ALLOW_RESIZE` - Buffer will resize on buffer update if a different amount of
##        data is passed. If this flag is not specified, and more data is passed on update, the buffer
##        will be trimmed to fit the existing buffer size. This flag has effect only on dynamic buffers.
##    - `BUFFER_INDEX32` - Buffer is using 32-bit indices. This flag has effect only on index buffers.
##
##  @returns Static vertex buffer handle.
##
##

proc create_vertex_buffer*(mem: ptr memory_t;
                               decl: ptr vertex_decl_t; flags: uint16): vertex_buffer_handle_t {.
    cdecl, importc: "bgfx_create_vertex_buffer", dynlib: lib.}
## *
##  Set static vertex buffer debug name.
##
##  @param[in] _handle Static vertex buffer handle.
##  @param[in] _name Static vertex buffer name.
##  @param[in] _len Static vertex buffer name length (if length is INT32_MAX, it's expected
##   that _name is zero terminated string.
##
##

proc set_vertex_buffer_name*(handle: vertex_buffer_handle_t;
                                 name: cstring; len: int32_t) {.cdecl,
    importc: "bgfx_set_vertex_buffer_name", dynlib: lib.}
## *
##  Destroy static vertex buffer.
##
##  @param[in] _handle Static vertex buffer handle.
##
##

proc destroy_vertex_buffer*(handle: vertex_buffer_handle_t) {.cdecl,
    importc: "bgfx_destroy_vertex_buffer", dynlib: lib.}
## *
##  Create empty dynamic index buffer.
##
##  @param[in] _num Number of indices.
##  @param[in] _flags Buffer creation flags.
##     - `BUFFER_NONE` - No flags.
##     - `BUFFER_COMPUTE_READ` - Buffer will be read from by compute shader.
##     - `BUFFER_COMPUTE_WRITE` - Buffer will be written into by compute shader. When buffer
##         is created with `BUFFER_COMPUTE_WRITE` flag it cannot be updated from CPU.
##     - `BUFFER_COMPUTE_READ_WRITE` - Buffer will be used for read/write by compute shader.
##     - `BUFFER_ALLOW_RESIZE` - Buffer will resize on buffer update if a different amount of
##         data is passed. If this flag is not specified, and more data is passed on update, the buffer
##         will be trimmed to fit the existing buffer size. This flag has effect only on dynamic
##         buffers.
##     - `BUFFER_INDEX32` - Buffer is using 32-bit indices. This flag has effect only on
##         index buffers.
##
##  @returns Dynamic index buffer handle.
##
##

proc create_dynamic_index_buffer*(num: uint32; flags: uint16): dynamic_index_buffer_handle_t {.
    cdecl, importc: "bgfx_create_dynamic_index_buffer", dynlib: lib.}
## *
##  Create dynamic index buffer and initialized it.
##
##  @param[in] _mem Index buffer data.
##  @param[in] _flags Buffer creation flags.
##     - `BUFFER_NONE` - No flags.
##     - `BUFFER_COMPUTE_READ` - Buffer will be read from by compute shader.
##     - `BUFFER_COMPUTE_WRITE` - Buffer will be written into by compute shader. When buffer
##         is created with `BUFFER_COMPUTE_WRITE` flag it cannot be updated from CPU.
##     - `BUFFER_COMPUTE_READ_WRITE` - Buffer will be used for read/write by compute shader.
##     - `BUFFER_ALLOW_RESIZE` - Buffer will resize on buffer update if a different amount of
##         data is passed. If this flag is not specified, and more data is passed on update, the buffer
##         will be trimmed to fit the existing buffer size. This flag has effect only on dynamic
##         buffers.
##     - `BUFFER_INDEX32` - Buffer is using 32-bit indices. This flag has effect only on
##         index buffers.
##
##  @returns Dynamic index buffer handle.
##
##

proc create_dynamic_index_buffer_mem*(mem: ptr memory_t; flags: uint16): dynamic_index_buffer_handle_t {.
    cdecl, importc: "bgfx_create_dynamic_index_buffer_mem", dynlib: lib.}
## *
##  Update dynamic index buffer.
##
##  @param[in] _handle Dynamic index buffer handle.
##  @param[in] _startIndex Start index.
##  @param[in] _mem Index buffer data.
##
##

proc update_dynamic_index_buffer*(handle: dynamic_index_buffer_handle_t;
                                      startIndex: uint32;
                                      mem: ptr memory_t) {.cdecl,
    importc: "bgfx_update_dynamic_index_buffer", dynlib: lib.}
## *
##  Destroy dynamic index buffer.
##
##  @param[in] _handle Dynamic index buffer handle.
##
##

proc destroy_dynamic_index_buffer*(handle: dynamic_index_buffer_handle_t) {.
    cdecl, importc: "bgfx_destroy_dynamic_index_buffer", dynlib: lib.}
## *
##  Create empty dynamic vertex buffer.
##
##  @param[in] _num Number of vertices.
##  @param[in] _decl Vertex declaration.
##  @param[in] _flags Buffer creation flags.
##     - `BUFFER_NONE` - No flags.
##     - `BUFFER_COMPUTE_READ` - Buffer will be read from by compute shader.
##     - `BUFFER_COMPUTE_WRITE` - Buffer will be written into by compute shader. When buffer
##         is created with `BUFFER_COMPUTE_WRITE` flag it cannot be updated from CPU.
##     - `BUFFER_COMPUTE_READ_WRITE` - Buffer will be used for read/write by compute shader.
##     - `BUFFER_ALLOW_RESIZE` - Buffer will resize on buffer update if a different amount of
##         data is passed. If this flag is not specified, and more data is passed on update, the buffer
##         will be trimmed to fit the existing buffer size. This flag has effect only on dynamic
##         buffers.
##     - `BUFFER_INDEX32` - Buffer is using 32-bit indices. This flag has effect only on
##         index buffers.
##
##  @returns Dynamic vertex buffer handle.
##
##

proc create_dynamic_vertex_buffer*(num: uint32;
                                       decl: ptr vertex_decl_t;
                                       flags: uint16): dynamic_vertex_buffer_handle_t {.
    cdecl, importc: "bgfx_create_dynamic_vertex_buffer", dynlib: lib.}
## *
##  Create dynamic vertex buffer and initialize it.
##
##  @param[in] _mem Vertex buffer data.
##  @param[in] _decl Vertex declaration.
##  @param[in] _flags Buffer creation flags.
##     - `BUFFER_NONE` - No flags.
##     - `BUFFER_COMPUTE_READ` - Buffer will be read from by compute shader.
##     - `BUFFER_COMPUTE_WRITE` - Buffer will be written into by compute shader. When buffer
##         is created with `BUFFER_COMPUTE_WRITE` flag it cannot be updated from CPU.
##     - `BUFFER_COMPUTE_READ_WRITE` - Buffer will be used for read/write by compute shader.
##     - `BUFFER_ALLOW_RESIZE` - Buffer will resize on buffer update if a different amount of
##         data is passed. If this flag is not specified, and more data is passed on update, the buffer
##         will be trimmed to fit the existing buffer size. This flag has effect only on dynamic
##         buffers.
##     - `BUFFER_INDEX32` - Buffer is using 32-bit indices. This flag has effect only on
##         index buffers.
##
##  @returns Dynamic vertex buffer handle.
##
##

proc create_dynamic_vertex_buffer_mem*(mem: ptr memory_t;
    decl: ptr vertex_decl_t; flags: uint16): dynamic_vertex_buffer_handle_t {.
    cdecl, importc: "bgfx_create_dynamic_vertex_buffer_mem", dynlib: lib.}
## *
##  Update dynamic vertex buffer.
##
##  @param[in] _handle Dynamic vertex buffer handle.
##  @param[in] _startVertex Start vertex.
##  @param[in] _mem Vertex buffer data.
##
##

proc update_dynamic_vertex_buffer*(handle: dynamic_vertex_buffer_handle_t;
                                       startVertex: uint32;
                                       mem: ptr memory_t) {.cdecl,
    importc: "bgfx_update_dynamic_vertex_buffer", dynlib: lib.}
## *
##  Destroy dynamic vertex buffer.
##
##  @param[in] _handle Dynamic vertex buffer handle.
##
##

proc destroy_dynamic_vertex_buffer*(handle: dynamic_vertex_buffer_handle_t) {.
    cdecl, importc: "bgfx_destroy_dynamic_vertex_buffer", dynlib: lib.}
## *
##  Returns number of requested or maximum available indices.
##
##  @param[in] _num Number of required indices.
##
##  @returns Number of requested or maximum available indices.
##
##

proc get_avail_transient_index_buffer*(num: uint32): uint32 {.cdecl,
    importc: "bgfx_get_avail_transient_index_buffer", dynlib: lib.}
## *
##  Returns number of requested or maximum available vertices.
##
##  @param[in] _num Number of required vertices.
##  @param[in] _decl Vertex declaration.
##
##  @returns Number of requested or maximum available vertices.
##
##

proc get_avail_transient_vertex_buffer*(num: uint32;
    decl: ptr vertex_decl_t): uint32 {.cdecl,
    importc: "bgfx_get_avail_transient_vertex_buffer", dynlib: lib.}
## *
##  Returns number of requested or maximum available instance buffer slots.
##
##  @param[in] _num Number of required instances.
##  @param[in] _stride Stride per instance.
##
##  @returns Number of requested or maximum available instance buffer slots.
##
##

proc get_avail_instance_data_buffer*(num: uint32; stride: uint16): uint32 {.
    cdecl, importc: "bgfx_get_avail_instance_data_buffer", dynlib: lib.}
## *
##  Allocate transient index buffer.
##  @remarks
##    Only 16-bit index buffer is supported.
##
##  @param[out] _tib TransientIndexBuffer structure is filled and is valid
##   for the duration of frame, and it can be reused for multiple draw
##   calls.
##  @param[in] _num Number of indices to allocate.
##
##

proc alloc_transient_index_buffer*(tib: ptr transient_index_buffer_t;
                                       num: uint32) {.cdecl,
    importc: "bgfx_alloc_transient_index_buffer", dynlib: lib.}
## *
##  Allocate transient vertex buffer.
##
##  @param[out] _tvb TransientVertexBuffer structure is filled and is valid
##   for the duration of frame, and it can be reused for multiple draw
##   calls.
##  @param[in] _num Number of vertices to allocate.
##  @param[in] _decl Vertex declaration.
##
##

proc alloc_transient_vertex_buffer*(tvb: ptr transient_vertex_buffer_t;
                                        num: uint32;
                                        decl: ptr vertex_decl_t) {.cdecl,
    importc: "bgfx_alloc_transient_vertex_buffer", dynlib: lib.}
## *
##  Check for required space and allocate transient vertex and index
##  buffers. If both space requirements are satisfied function returns
##  true.
##  @remarks
##    Only 16-bit index buffer is supported.
##
##  @param[out] _tvb TransientVertexBuffer structure is filled and is valid
##   for the duration of frame, and it can be reused for multiple draw
##   calls.
##  @param[in] _decl Number of vertices to allocate.
##  @param[in] _numVertices Vertex declaration.
##  @param[out] _tib TransientIndexBuffer structure is filled and is valid
##   for the duration of frame, and it can be reused for multiple draw
##   calls.
##  @param[in] _numIndices Number of indices to allocate.
##
##

proc alloc_transient_buffers*(tvb: ptr transient_vertex_buffer_t;
                                  decl: ptr vertex_decl_t;
                                  numVertices: uint32;
                                  tib: ptr transient_index_buffer_t;
                                  numIndices: uint32): bool {.cdecl,
    importc: "bgfx_alloc_transient_buffers", dynlib: lib.}
## *
##  Allocate instance data buffer.
##
##  @param[out] _idb InstanceDataBuffer structure is filled and is valid
##   for duration of frame, and it can be reused for multiple draw
##   calls.
##  @param[in] _num Number of instances.
##  @param[in] _stride Instance stride. Must be multiple of 16.
##
##

proc alloc_instance_data_buffer*(idb: ptr instance_data_buffer_t;
                                     num: uint32; stride: uint16) {.cdecl,
    importc: "bgfx_alloc_instance_data_buffer", dynlib: lib.}
## *
##  Create draw indirect buffer.
##
##  @param[in] _num Number of indirect calls.
##
##  @returns Indirect buffer handle.
##
##

proc create_indirect_buffer*(num: uint32): indirect_buffer_handle_t {.
    cdecl, importc: "bgfx_create_indirect_buffer", dynlib: lib.}
## *
##  Destroy draw indirect buffer.
##
##  @param[in] _handle Indirect buffer handle.
##
##

proc destroy_indirect_buffer*(handle: indirect_buffer_handle_t) {.cdecl,
    importc: "bgfx_destroy_indirect_buffer", dynlib: lib.}
## *
##  Create shader from memory buffer.
##
##  @param[in] _mem Shader binary.
##
##  @returns Shader handle.
##
##

proc create_shader*(mem: ptr memory_t): shader_handle_t {.cdecl,
    importc: "bgfx_create_shader", dynlib: lib.}
## *
##  Returns the number of uniforms and uniform handles used inside a shader.
##  @remarks
##    Only non-predefined uniforms are returned.
##
##  @param[in] _handle Shader handle.
##  @param[out] _uniforms UniformHandle array where data will be stored.
##  @param[in] _max Maximum capacity of array.
##
##  @returns Number of uniforms used by shader.
##
##

proc get_shader_uniforms*(handle: shader_handle_t;
                              uniforms: ptr uniform_handle_t; max: uint16): uint16 {.
    cdecl, importc: "bgfx_get_shader_uniforms", dynlib: lib.}
## *
##  Set shader debug name.
##
##  @param[in] _handle Shader handle.
##  @param[in] _name Shader name.
##  @param[in] _len Shader name length (if length is INT32_MAX, it's expected
##   that _name is zero terminated string).
##
##

proc set_shader_name*(handle: shader_handle_t; name: cstring;
                          len: int32_t) {.cdecl, importc: "bgfx_set_shader_name",
    dynlib: lib.}
## *
##  Destroy shader.
##  @remark Once a shader program is created with _handle,
##    it is safe to destroy that shader.
##
##  @param[in] _handle Shader handle.
##
##

proc destroy_shader*(handle: shader_handle_t) {.cdecl,
    importc: "bgfx_destroy_shader", dynlib: lib.}
## *
##  Create program with vertex and fragment shaders.
##
##  @param[in] _vsh Vertex shader.
##  @param[in] _fsh Fragment shader.
##  @param[in] _destroyShaders If true, shaders will be destroyed when program is destroyed.
##
##  @returns Program handle if vertex shader output and fragment shader
##   input are matching, otherwise returns invalid program handle.
##
##

proc create_program*(vsh: shader_handle_t; fsh: shader_handle_t;
                         destroyShaders: bool): program_handle_t {.cdecl,
    importc: "bgfx_create_program", dynlib: lib.}
## *
##  Create program with compute shader.
##
##  @param[in] _csh Compute shader.
##  @param[in] _destroyShaders If true, shaders will be destroyed when program is destroyed.
##
##  @returns Program handle.
##
##

proc create_compute_program*(csh: shader_handle_t; destroyShaders: bool): program_handle_t {.
    cdecl, importc: "bgfx_create_compute_program", dynlib: lib.}
## *
##  Destroy program.
##
##  @param[in] _handle Program handle.
##
##

proc destroy_program*(handle: program_handle_t) {.cdecl,
    importc: "bgfx_destroy_program", dynlib: lib.}
## *
##  Validate texture parameters.
##
##  @param[in] _depth Depth dimension of volume texture.
##  @param[in] _cubeMap Indicates that texture contains cubemap.
##  @param[in] _numLayers Number of layers in texture array.
##  @param[in] _format Texture format. See: `TextureFormat::Enum`.
##  @param[in] _flags Texture flags. See `TEXTURE_*`.
##
##  @returns True if texture can be successfully created.
##
##

proc is_texture_valid*(depth: uint16; cubeMap: bool; numLayers: uint16;
                           format: texture_format_t; flags: uint64): bool {.
    cdecl, importc: "bgfx_is_texture_valid", dynlib: lib.}
## *
##  Calculate amount of memory required for texture.
##
##  @param[out] _info Resulting texture info structure. See: `TextureInfo`.
##  @param[in] _width Width.
##  @param[in] _height Height.
##  @param[in] _depth Depth dimension of volume texture.
##  @param[in] _cubeMap Indicates that texture contains cubemap.
##  @param[in] _hasMips Indicates that texture contains full mip-map chain.
##  @param[in] _numLayers Number of layers in texture array.
##  @param[in] _format Texture format. See: `TextureFormat::Enum`.
##
##

proc calc_texture_size*(info: ptr texture_info_t; width: uint16;
                            height: uint16; depth: uint16; cubeMap: bool;
                            hasMips: bool; numLayers: uint16;
                            format: texture_format_t) {.cdecl,
    importc: "bgfx_calc_texture_size", dynlib: lib.}
## *
##  Create texture from memory buffer.
##
##  @param[in] _mem DDS, KTX or PVR texture binary data.
##  @param[in] _flags Texture creation (see `TEXTURE_*`.), and sampler (see `SAMPLER_*`)
##   flags. Default texture sampling mode is linear, and wrap mode is repeat.
##   - `SAMPLER_[U/V/W]_[MIRROR/CLAMP]` - Mirror or clamp to edge wrap
##     mode.
##   - `SAMPLER_[MIN/MAG/MIP]_[POINT/ANISOTROPIC]` - Point or anisotropic
##     sampling.
##  @param[in] _skip Skip top level mips when parsing texture.
##  @param[out] _info When non-`NULL` is specified it returns parsed texture information.
##
##  @returns Texture handle.
##
##

proc create_texture*(mem: ptr memory_t; flags: uint64; skip: uint8_t;
                         info: ptr texture_info_t): texture_handle_t {.
    cdecl, importc: "bgfx_create_texture", dynlib: lib.}
## *
##  Create 2D texture.
##
##  @param[in] _width Width.
##  @param[in] _height Height.
##  @param[in] _hasMips Indicates that texture contains full mip-map chain.
##  @param[in] _numLayers Number of layers in texture array. Must be 1 if caps
##   `CAPS_TEXTURE_2D_ARRAY` flag is not set.
##  @param[in] _format Texture format. See: `TextureFormat::Enum`.
##  @param[in] _flags Texture creation (see `TEXTURE_*`.), and sampler (see `SAMPLER_*`)
##   flags. Default texture sampling mode is linear, and wrap mode is repeat.
##   - `SAMPLER_[U/V/W]_[MIRROR/CLAMP]` - Mirror or clamp to edge wrap
##     mode.
##   - `SAMPLER_[MIN/MAG/MIP]_[POINT/ANISOTROPIC]` - Point or anisotropic
##     sampling.
##  @param[in] _mem Texture data. If `_mem` is non-NULL, created texture will be immutable. If
##   `_mem` is NULL content of the texture is uninitialized. When `_numLayers` is more than
##   1, expected memory layout is texture and all mips together for each array element.
##
##  @returns Texture handle.
##
##

proc create_texture_2d*(width: uint16; height: uint16; hasMips: bool;
                            numLayers: uint16; format: texture_format_t;
                            flags: uint64; mem: ptr memory_t): texture_handle_t {.
    cdecl, importc: "bgfx_create_texture_2d", dynlib: lib.}
## *
##  Create texture with size based on backbuffer ratio. Texture will maintain ratio
##  if back buffer resolution changes.
##
##  @param[in] _ratio Texture size in respect to back-buffer size. See: `BackbufferRatio::Enum`.
##  @param[in] _hasMips Indicates that texture contains full mip-map chain.
##  @param[in] _numLayers Number of layers in texture array. Must be 1 if caps
##   `CAPS_TEXTURE_2D_ARRAY` flag is not set.
##  @param[in] _format Texture format. See: `TextureFormat::Enum`.
##  @param[in] _flags Texture creation (see `TEXTURE_*`.), and sampler (see `SAMPLER_*`)
##   flags. Default texture sampling mode is linear, and wrap mode is repeat.
##   - `SAMPLER_[U/V/W]_[MIRROR/CLAMP]` - Mirror or clamp to edge wrap
##     mode.
##   - `SAMPLER_[MIN/MAG/MIP]_[POINT/ANISOTROPIC]` - Point or anisotropic
##     sampling.
##
##  @returns Texture handle.
##
##

proc create_texture_2d_scaled*(ratio: backbuffer_ratio_t;
                                   hasMips: bool; numLayers: uint16;
                                   format: texture_format_t;
                                   flags: uint64): texture_handle_t {.
    cdecl, importc: "bgfx_create_texture_2d_scaled", dynlib: lib.}
## *
##  Create 3D texture.
##
##  @param[in] _width Width.
##  @param[in] _height Height.
##  @param[in] _depth Depth.
##  @param[in] _hasMips Indicates that texture contains full mip-map chain.
##  @param[in] _format Texture format. See: `TextureFormat::Enum`.
##  @param[in] _flags Texture creation (see `TEXTURE_*`.), and sampler (see `SAMPLER_*`)
##   flags. Default texture sampling mode is linear, and wrap mode is repeat.
##   - `SAMPLER_[U/V/W]_[MIRROR/CLAMP]` - Mirror or clamp to edge wrap
##     mode.
##   - `SAMPLER_[MIN/MAG/MIP]_[POINT/ANISOTROPIC]` - Point or anisotropic
##     sampling.
##  @param[in] _mem Texture data. If `_mem` is non-NULL, created texture will be immutable. If
##   `_mem` is NULL content of the texture is uninitialized. When `_numLayers` is more than
##   1, expected memory layout is texture and all mips together for each array element.
##
##  @returns Texture handle.
##
##

proc create_texture_3d*(width: uint16; height: uint16; depth: uint16;
                            hasMips: bool; format: texture_format_t;
                            flags: uint64; mem: ptr memory_t): texture_handle_t {.
    cdecl, importc: "bgfx_create_texture_3d", dynlib: lib.}
## *
##  Create Cube texture.
##
##  @param[in] _size Cube side size.
##  @param[in] _hasMips Indicates that texture contains full mip-map chain.
##  @param[in] _numLayers Number of layers in texture array. Must be 1 if caps
##   `CAPS_TEXTURE_2D_ARRAY` flag is not set.
##  @param[in] _format Texture format. See: `TextureFormat::Enum`.
##  @param[in] _flags Texture creation (see `TEXTURE_*`.), and sampler (see `SAMPLER_*`)
##   flags. Default texture sampling mode is linear, and wrap mode is repeat.
##   - `SAMPLER_[U/V/W]_[MIRROR/CLAMP]` - Mirror or clamp to edge wrap
##     mode.
##   - `SAMPLER_[MIN/MAG/MIP]_[POINT/ANISOTROPIC]` - Point or anisotropic
##     sampling.
##  @param[in] _mem Texture data. If `_mem` is non-NULL, created texture will be immutable. If
##   `_mem` is NULL content of the texture is uninitialized. When `_numLayers` is more than
##   1, expected memory layout is texture and all mips together for each array element.
##
##  @returns Texture handle.
##
##

proc create_texture_cube*(size: uint16; hasMips: bool; numLayers: uint16;
                              format: texture_format_t; flags: uint64;
                              mem: ptr memory_t): texture_handle_t {.
    cdecl, importc: "bgfx_create_texture_cube", dynlib: lib.}
## *
##  Update 2D texture.
##
##  @param[in] _handle Texture handle.
##  @param[in] _layer Layer in texture array.
##  @param[in] _mip Mip level.
##  @param[in] _x X offset in texture.
##  @param[in] _y Y offset in texture.
##  @param[in] _width Width of texture block.
##  @param[in] _height Height of texture block.
##  @param[in] _mem Texture update data.
##  @param[in] _pitch Pitch of input image (bytes). When _pitch is set to
##   UINT16_MAX, it will be calculated internally based on _width.
##
##

proc update_texture_2d*(handle: texture_handle_t; layer: uint16;
                            mip: uint8_t; x: uint16; y: uint16;
                            width: uint16; height: uint16;
                            mem: ptr memory_t; pitch: uint16) {.cdecl,
    importc: "bgfx_update_texture_2d", dynlib: lib.}
## *
##  Update 3D texture.
##
##  @param[in] _handle Texture handle.
##  @param[in] _mip Mip level.
##  @param[in] _x X offset in texture.
##  @param[in] _y Y offset in texture.
##  @param[in] _z Z offset in texture.
##  @param[in] _width Width of texture block.
##  @param[in] _height Height of texture block.
##  @param[in] _depth Depth of texture block.
##  @param[in] _mem Texture update data.
##
##

proc update_texture_3d*(handle: texture_handle_t; mip: uint8_t;
                            x: uint16; y: uint16; z: uint16;
                            width: uint16; height: uint16; depth: uint16;
                            mem: ptr memory_t) {.cdecl,
    importc: "bgfx_update_texture_3d", dynlib: lib.}
## *
##  Update Cube texture.
##
##  @param[in] _handle Texture handle.
##  @param[in] _layer Layer in texture array.
##  @param[in] _side Cubemap side `CUBE_MAP_<POSITIVE or NEGATIVE>_<X, Y or Z>`,
##     where 0 is +X, 1 is -X, 2 is +Y, 3 is -Y, 4 is +Z, and 5 is -Z.
##                    +----------+
##                    |-z       2|
##                    | ^  +y    |
##                    | |        |    Unfolded cube:
##                    | +---->+x |
##         +----------+----------+----------+----------+
##         |+y       1|+y       4|+y       0|+y       5|
##         | ^  -x    | ^  +z    | ^  +x    | ^  -z    |
##         | |        | |        | |        | |        |
##         | +---->+z | +---->+x | +---->-z | +---->-x |
##         +----------+----------+----------+----------+
##                    |+z       3|
##                    | ^  -y    |
##                    | |        |
##                    | +---->+x |
##                    +----------+
##  @param[in] _mip Mip level.
##  @param[in] _x X offset in texture.
##  @param[in] _y Y offset in texture.
##  @param[in] _width Width of texture block.
##  @param[in] _height Height of texture block.
##  @param[in] _mem Texture update data.
##  @param[in] _pitch Pitch of input image (bytes). When _pitch is set to
##   UINT16_MAX, it will be calculated internally based on _width.
##
##

proc update_texture_cube*(handle: texture_handle_t; layer: uint16;
                              side: uint8_t; mip: uint8_t; x: uint16;
                              y: uint16; width: uint16; height: uint16;
                              mem: ptr memory_t; pitch: uint16) {.cdecl,
    importc: "bgfx_update_texture_cube", dynlib: lib.}
## *
##  Read back texture content.
##  @attention Texture must be created with `TEXTURE_READ_BACK` flag.
##  @attention Availability depends on: `CAPS_TEXTURE_READ_BACK`.
##
##  @param[in] _handle Texture handle.
##  @param[in] _data Destination buffer.
##  @param[in] _mip Mip level.
##
##  @returns Frame number when the result will be available. See: `bgfx::frame`.
##
##

proc read_texture*(handle: texture_handle_t; data: pointer; mip: uint8_t): uint32 {.
    cdecl, importc: "bgfx_read_texture", dynlib: lib.}
## *
##  Set texture debug name.
##
##  @param[in] _handle Texture handle.
##  @param[in] _name Texture name.
##  @param[in] _len Texture name length (if length is INT32_MAX, it's expected
##   that _name is zero terminated string.
##
##

proc set_texture_name*(handle: texture_handle_t; name: cstring;
                           len: int32_t) {.cdecl,
    importc: "bgfx_set_texture_name", dynlib: lib.}
## *
##  Returns texture direct access pointer.
##  @attention Availability depends on: `CAPS_TEXTURE_DIRECT_ACCESS`. This feature
##    is available on GPUs that have unified memory architecture (UMA) support.
##
##  @param[in] _handle Texture handle.
##
##  @returns Pointer to texture memory. If returned pointer is `NULL` direct access
##   is not available for this texture. If pointer is `UINTPTR_MAX` sentinel value
##   it means texture is pending creation. Pointer returned can be cached and it
##   will be valid until texture is destroyed.
##
##

proc get_direct_access_ptr*(handle: texture_handle_t): pointer {.cdecl,
    importc: "bgfx_get_direct_access_ptr", dynlib: lib.}
## *
##  Destroy texture.
##
##  @param[in] _handle Texture handle.
##
##

proc destroy_texture*(handle: texture_handle_t) {.cdecl,
    importc: "bgfx_destroy_texture", dynlib: lib.}
## *
##  Create frame buffer (simple).
##
##  @param[in] _width Texture width.
##  @param[in] _height Texture height.
##  @param[in] _format Texture format. See: `TextureFormat::Enum`.
##  @param[in] _textureFlags Texture creation (see `TEXTURE_*`.), and sampler (see `SAMPLER_*`)
##   flags. Default texture sampling mode is linear, and wrap mode is repeat.
##   - `SAMPLER_[U/V/W]_[MIRROR/CLAMP]` - Mirror or clamp to edge wrap
##     mode.
##   - `SAMPLER_[MIN/MAG/MIP]_[POINT/ANISOTROPIC]` - Point or anisotropic
##     sampling.
##
##  @returns Frame buffer handle.
##
##

proc create_frame_buffer*(width: uint16; height: uint16;
                              format: texture_format_t;
                              textureFlags: uint64): frame_buffer_handle_t {.
    cdecl, importc: "bgfx_create_frame_buffer", dynlib: lib.}
## *
##  Create frame buffer with size based on backbuffer ratio. Frame buffer will maintain ratio
##  if back buffer resolution changes.
##
##  @param[in] _ratio Frame buffer size in respect to back-buffer size. See:
##   `BackbufferRatio::Enum`.
##  @param[in] _format Texture format. See: `TextureFormat::Enum`.
##  @param[in] _textureFlags Texture creation (see `TEXTURE_*`.), and sampler (see `SAMPLER_*`)
##   flags. Default texture sampling mode is linear, and wrap mode is repeat.
##   - `SAMPLER_[U/V/W]_[MIRROR/CLAMP]` - Mirror or clamp to edge wrap
##     mode.
##   - `SAMPLER_[MIN/MAG/MIP]_[POINT/ANISOTROPIC]` - Point or anisotropic
##     sampling.
##
##  @returns Frame buffer handle.
##
##

proc create_frame_buffer_scaled*(ratio: backbuffer_ratio_t;
                                     format: texture_format_t;
                                     textureFlags: uint64): frame_buffer_handle_t {.
    cdecl, importc: "bgfx_create_frame_buffer_scaled", dynlib: lib.}
## *
##  Create MRT frame buffer from texture handles (simple).
##
##  @param[in] _num Number of texture handles.
##  @param[in] _handles Texture attachments.
##  @param[in] _destroyTexture If true, textures will be destroyed when
##   frame buffer is destroyed.
##
##  @returns Frame buffer handle.
##
##

proc create_frame_buffer_from_handles*(num: uint8_t;
    handles: ptr texture_handle_t; destroyTexture: bool): frame_buffer_handle_t {.
    cdecl, importc: "bgfx_create_frame_buffer_from_handles", dynlib: lib.}
## *
##  Create MRT frame buffer from texture handles with specific layer and
##  mip level.
##
##  @param[in] _num Number of attachements.
##  @param[in] _attachment Attachment texture info. See: `bgfx::Attachment`.
##  @param[in] _destroyTexture If true, textures will be destroyed when
##   frame buffer is destroyed.
##
##  @returns Frame buffer handle.
##
##

proc create_frame_buffer_from_attachment*(num: uint8_t;
    attachment: ptr attachment_t; destroyTexture: bool): frame_buffer_handle_t {.
    cdecl, importc: "bgfx_create_frame_buffer_from_attachment", dynlib: lib.}
## *
##  Create frame buffer for multiple window rendering.
##  @remarks
##    Frame buffer cannot be used for sampling.
##  @attention Availability depends on: `CAPS_SWAP_CHAIN`.
##
##  @param[in] _nwh OS' target native window handle.
##  @param[in] _width Window back buffer width.
##  @param[in] _height Window back buffer height.
##  @param[in] _format Window back buffer color format.
##  @param[in] _depthFormat Window back buffer depth format.
##
##  @returns Frame buffer handle.
##
##

proc create_frame_buffer_from_nwh*(nwh: pointer; width: uint16;
                                       height: uint16;
                                       format: texture_format_t;
                                       depthFormat: texture_format_t): frame_buffer_handle_t {.
    cdecl, importc: "bgfx_create_frame_buffer_from_nwh", dynlib: lib.}
## *
##  Set frame buffer debug name.
##
##  @param[in] _handle Frame buffer handle.
##  @param[in] _name Frame buffer name.
##  @param[in] _len Frame buffer name length (if length is INT32_MAX, it's expected
##   that _name is zero terminated string.
##
##

proc set_frame_buffer_name*(handle: frame_buffer_handle_t;
                                name: cstring; len: int32_t) {.cdecl,
    importc: "bgfx_set_frame_buffer_name", dynlib: lib.}
## *
##  Obtain texture handle of frame buffer attachment.
##
##  @param[in] _handle Frame buffer handle.
##  @param[in] _attachment
##
##

proc get_texture*(handle: frame_buffer_handle_t; attachment: uint8_t): texture_handle_t {.
    cdecl, importc: "bgfx_get_texture", dynlib: lib.}
## *
##  Destroy frame buffer.
##
##  @param[in] _handle Frame buffer handle.
##
##

proc destroy_frame_buffer*(handle: frame_buffer_handle_t) {.cdecl,
    importc: "bgfx_destroy_frame_buffer", dynlib: lib.}
## *
##  Create shader uniform parameter.
##  @remarks
##    1. Uniform names are unique. It's valid to call `bgfx::createUniform`
##       multiple times with the same uniform name. The library will always
##       return the same handle, but the handle reference count will be
##       incremented. This means that the same number of `bgfx::destroyUniform`
##       must be called to properly destroy the uniform.
##    2. Predefined uniforms (declared in `bgfx_shader.sh`):
##       - `u_viewRect vec4(x, y, width, height)` - view rectangle for current
##         view, in pixels.
##       - `u_viewTexel vec4(1.0/width, 1.0/height, undef, undef)` - inverse
##         width and height
##       - `u_view mat4` - view matrix
##       - `u_invView mat4` - inverted view matrix
##       - `u_proj mat4` - projection matrix
##       - `u_invProj mat4` - inverted projection matrix
##       - `u_viewProj mat4` - concatenated view projection matrix
##       - `u_invViewProj mat4` - concatenated inverted view projection matrix
##       - `u_model mat4[CONFIG_MAX_BONES]` - array of model matrices.
##       - `u_modelView mat4` - concatenated model view matrix, only first
##         model matrix from array is used.
##       - `u_modelViewProj mat4` - concatenated model view projection matrix.
##       - `u_alphaRef float` - alpha reference value for alpha test.
##
##  @param[in] _name Uniform name in shader.
##  @param[in] _type Type of uniform (See: `bgfx::UniformType`).
##  @param[in] _num Number of elements in array.
##
##  @returns Handle to uniform object.
##
##

proc create_uniform*(name: cstring; type: uniform_type_t; num: uint16): uniform_handle_t {.
    cdecl, importc: "bgfx_create_uniform", dynlib: lib.}
## *
##  Retrieve uniform info.
##
##  @param[in] _handle Handle to uniform object.
##  @param[out] _info Uniform info.
##
##

proc get_uniform_info*(handle: uniform_handle_t;
                           info: ptr uniform_info_t) {.cdecl,
    importc: "bgfx_get_uniform_info", dynlib: lib.}
## *
##  Destroy shader uniform parameter.
##
##  @param[in] _handle Handle to uniform object.
##
##

proc destroy_uniform*(handle: uniform_handle_t) {.cdecl,
    importc: "bgfx_destroy_uniform", dynlib: lib.}
## *
##  Create occlusion query.
##
##

proc create_occlusion_query*(): occlusion_query_handle_t {.cdecl,
    importc: "bgfx_create_occlusion_query", dynlib: lib.}
## *
##  Retrieve occlusion query result from previous frame.
##
##  @param[in] _handle Handle to occlusion query object.
##  @param[out] _result Number of pixels that passed test. This argument
##   can be `NULL` if result of occlusion query is not needed.
##
##  @returns Occlusion query result.
##
##

proc get_result*(handle: occlusion_query_handle_t; result: ptr int32_t): occlusion_query_result_t {.
    cdecl, importc: "bgfx_get_result", dynlib: lib.}
## *
##  Destroy occlusion query.
##
##  @param[in] _handle Handle to occlusion query object.
##
##

proc destroy_occlusion_query*(handle: occlusion_query_handle_t) {.cdecl,
    importc: "bgfx_destroy_occlusion_query", dynlib: lib.}
## *
##  Set palette color value.
##
##  @param[in] _index Index into palette.
##  @param[in] _rgba RGBA floating point values.
##
##

proc set_palette_color*(index: uint8_t; rgba: array[4, cfloat]) {.cdecl,
    importc: "bgfx_set_palette_color", dynlib: lib.}
## *
##  Set palette color value.
##
##  @param[in] _index Index into palette.
##  @param[in] _rgba Packed 32-bit RGBA value.
##
##

proc set_palette_color_rgba8*(index: uint8_t; rgba: uint32) {.cdecl,
    importc: "bgfx_set_palette_color_rgba8", dynlib: lib.}
## *
##  Set view name.
##  @remarks
##    This is debug only feature.
##    In graphics debugger view name will appear as:
##        "nnnc <view name>"
##         ^  ^ ^
##         |  +--- compute (C)
##         +------ view id
##
##  @param[in] _id View id.
##  @param[in] _name View name.
##
##

proc set_view_name*(id: view_id_t; name: cstring) {.cdecl,
    importc: "bgfx_set_view_name", dynlib: lib.}
## *
##  Set view rectangle. Draw primitive outside view will be clipped.
##
##  @param[in] _id View id.
##  @param[in] _x Position x from the left corner of the window.
##  @param[in] _y Position y from the top corner of the window.
##  @param[in] _width Width of view port region.
##  @param[in] _height Height of view port region.
##
##

proc set_view_rect*(id: view_id_t; x: uint16; y: uint16;
                        width: uint16; height: uint16) {.cdecl,
    importc: "bgfx_set_view_rect", dynlib: lib.}
## *
##  Set view rectangle. Draw primitive outside view will be clipped.
##
##  @param[in] _id View id.
##  @param[in] _x Position x from the left corner of the window.
##  @param[in] _y Position y from the top corner of the window.
##  @param[in] _ratio Width and height will be set in respect to back-buffer size.
##   See: `BackbufferRatio::Enum`.
##
##

proc set_view_rect_ratio*(id: view_id_t; x: uint16; y: uint16;
                              ratio: backbuffer_ratio_t) {.cdecl,
    importc: "bgfx_set_view_rect_ratio", dynlib: lib.}
## *
##  Set view scissor. Draw primitive outside view will be clipped. When
##  _x, _y, _width and _height are set to 0, scissor will be disabled.
##
##  @param[in] _id View id.
##  @param[in] _x Position x from the left corner of the window.
##  @param[in] _y Position y from the top corner of the window.
##  @param[in] _width Width of view scissor region.
##  @param[in] _height Height of view scissor region.
##
##

proc set_view_scissor*(id: view_id_t; x: uint16; y: uint16;
                           width: uint16; height: uint16) {.cdecl,
    importc: "bgfx_set_view_scissor", dynlib: lib.}
## *
##  Set view clear flags.
##
##  @param[in] _id View id.
##  @param[in] _flags Clear flags. Use `CLEAR_NONE` to remove any clear
##   operation. See: `CLEAR_*`.
##  @param[in] _rgba Color clear value.
##  @param[in] _depth Depth clear value.
##  @param[in] _stencil Stencil clear value.
##
##

proc set_view_clear*(id: view_id_t; flags: uint16; rgba: uint32;
                         depth: cfloat; stencil: uint8_t) {.cdecl,
    importc: "bgfx_set_view_clear", dynlib: lib.}
## *
##  Set view clear flags with different clear color for each
##  frame buffer texture. Must use `bgfx::setPaletteColor` to setup clear color
##  palette.
##
##  @param[in] _id View id.
##  @param[in] _flags Clear flags. Use `CLEAR_NONE` to remove any clear
##   operation. See: `CLEAR_*`.
##  @param[in] _depth Depth clear value.
##  @param[in] _stencil Stencil clear value.
##  @param[in] _c0 Palette index for frame buffer attachment 0.
##  @param[in] _c1 Palette index for frame buffer attachment 1.
##  @param[in] _c2 Palette index for frame buffer attachment 2.
##  @param[in] _c3 Palette index for frame buffer attachment 3.
##  @param[in] _c4 Palette index for frame buffer attachment 4.
##  @param[in] _c5 Palette index for frame buffer attachment 5.
##  @param[in] _c6 Palette index for frame buffer attachment 6.
##  @param[in] _c7 Palette index for frame buffer attachment 7.
##
##

proc set_view_clear_mrt*(id: view_id_t; flags: uint16; depth: cfloat;
                             stencil: uint8_t; c0: uint8_t; c1: uint8_t;
                             c2: uint8_t; c3: uint8_t; c4: uint8_t; c5: uint8_t;
                             c6: uint8_t; c7: uint8_t) {.cdecl,
    importc: "bgfx_set_view_clear_mrt", dynlib: lib.}
## *
##  Set view sorting mode.
##  @remarks
##    View mode must be set prior calling `bgfx::submit` for the view.
##
##  @param[in] _id View id.
##  @param[in] _mode View sort mode. See `ViewMode::Enum`.
##
##

proc set_view_mode*(id: view_id_t; mode: view_mode_t) {.cdecl,
    importc: "bgfx_set_view_mode", dynlib: lib.}
## *
##  Set view frame buffer.
##  @remarks
##    Not persistent after `bgfx::reset` call.
##
##  @param[in] _id View id.
##  @param[in] _handle Frame buffer handle. Passing `INVALID_HANDLE` as
##   frame buffer handle will draw primitives from this view into
##   default back buffer.
##
##

proc set_view_frame_buffer*(id: view_id_t;
                                handle: frame_buffer_handle_t) {.cdecl,
    importc: "bgfx_set_view_frame_buffer", dynlib: lib.}
## *
##  Set view view and projection matrices, all draw primitives in this
##  view will use these matrices.
##
##  @param[in] _id View id.
##  @param[in] _view View matrix.
##  @param[in] _proj Projection matrix.
##
##

proc set_view_transform*(id: view_id_t; view: pointer; proj: pointer) {.
    cdecl, importc: "bgfx_set_view_transform", dynlib: lib.}
## *
##  Post submit view reordering.
##
##  @param[in] _id First view id.
##  @param[in] _num Number of views to remap.
##  @param[in] _order View remap id table. Passing `NULL` will reset view ids
##   to default state.
##
##

proc set_view_order*(id: view_id_t; num: uint16;
                         order: ptr view_id_t) {.cdecl,
    importc: "bgfx_set_view_order", dynlib: lib.}
## *
##  Begin submitting draw calls from thread.
##
##  @param[in] _forThread Explicitly request an encoder for a worker thread.
##
##  @returns Encoder.
##
##

proc encoder_begin*(forThread: bool): ptr encoder_t {.cdecl,
    importc: "bgfx_encoder_begin", dynlib: lib.}
## *
##  End submitting draw calls from thread.
##
##  @param[in] _encoder Encoder.
##
##

proc encoder_end*(encoder: ptr encoder_t) {.cdecl,
    importc: "bgfx_encoder_end", dynlib: lib.}
## *
##  Sets a debug marker. This allows you to group graphics calls together for easy browsing in
##  graphics debugging tools.
##
##  @param[in] _marker Marker string.
##
##

proc encoder_set_marker*(this: ptr encoder_t; marker: cstring) {.cdecl,
    importc: "bgfx_encoder_set_marker", dynlib: lib.}
## *
##  Set render states for draw primitive.
##  @remarks
##    1. To setup more complex states use:
##       `STATE_ALPHA_REF(_ref)`,
##       `STATE_POINT_SIZE(_size)`,
##       `STATE_BLEND_FUNC(_src, _dst)`,
##       `STATE_BLEND_FUNC_SEPARATE(_srcRGB, _dstRGB, _srcA, _dstA)`,
##       `STATE_BLEND_EQUATION(_equation)`,
##       `STATE_BLEND_EQUATION_SEPARATE(_equationRGB, _equationA)`
##    2. `STATE_BLEND_EQUATION_ADD` is set when no other blend
##       equation is specified.
##
##  @param[in] _state State flags. Default state for primitive type is
##     triangles. See: `STATE_DEFAULT`.
##     - `STATE_DEPTH_TEST_*` - Depth test function.
##     - `STATE_BLEND_*` - See remark 1 about STATE_BLEND_FUNC.
##     - `STATE_BLEND_EQUATION_*` - See remark 2.
##     - `STATE_CULL_*` - Backface culling mode.
##     - `STATE_WRITE_*` - Enable R, G, B, A or Z write.
##     - `STATE_MSAA` - Enable hardware multisample antialiasing.
##     - `STATE_PT_[TRISTRIP/LINES/POINTS]` - Primitive type.
##  @param[in] _rgba Sets blend factor used by `STATE_BLEND_FACTOR` and
##     `STATE_BLEND_INV_FACTOR` blend modes.
##
##

proc encoder_set_state*(this: ptr encoder_t; state: uint64;
                            rgba: uint32) {.cdecl,
    importc: "bgfx_encoder_set_state", dynlib: lib.}
## *
##  Set condition for rendering.
##
##  @param[in] _handle Occlusion query handle.
##  @param[in] _visible Render if occlusion query is visible.
##
##

proc encoder_set_condition*(this: ptr encoder_t;
                                handle: occlusion_query_handle_t;
                                visible: bool) {.cdecl,
    importc: "bgfx_encoder_set_condition", dynlib: lib.}
## *
##  Set stencil test state.
##
##  @param[in] _fstencil Front stencil state.
##  @param[in] _bstencil Back stencil state. If back is set to `STENCIL_NONE`
##   _fstencil is applied to both front and back facing primitives.
##
##

proc encoder_set_stencil*(this: ptr encoder_t; fstencil: uint32;
                              bstencil: uint32) {.cdecl,
    importc: "bgfx_encoder_set_stencil", dynlib: lib.}
## *
##  Set scissor for draw primitive.
##  @remark
##    To scissor for all primitives in view see `bgfx::setViewScissor`.
##
##  @param[in] _x Position x from the left corner of the window.
##  @param[in] _y Position y from the top corner of the window.
##  @param[in] _width Width of view scissor region.
##  @param[in] _height Height of view scissor region.
##
##  @returns Scissor cache index.
##
##

proc encoder_set_scissor*(this: ptr encoder_t; x: uint16; y: uint16;
                              width: uint16; height: uint16): uint16 {.cdecl,
    importc: "bgfx_encoder_set_scissor", dynlib: lib.}
## *
##  Set scissor from cache for draw primitive.
##  @remark
##    To scissor for all primitives in view see `bgfx::setViewScissor`.
##
##  @param[in] _cache Index in scissor cache.
##
##

proc encoder_set_scissor_cached*(this: ptr encoder_t; cache: uint16) {.
    cdecl, importc: "bgfx_encoder_set_scissor_cached", dynlib: lib.}
## *
##  Set model matrix for draw primitive. If it is not called,
##  the model will be rendered with an identity model matrix.
##
##  @param[in] _mtx Pointer to first matrix in array.
##  @param[in] _num Number of matrices in array.
##
##  @returns Index into matrix cache in case the same model matrix has
##   to be used for other draw primitive call.
##
##

proc encoder_set_transform*(this: ptr encoder_t; mtx: pointer;
                                num: uint16): uint32 {.cdecl,
    importc: "bgfx_encoder_set_transform", dynlib: lib.}
## *
##   Set model matrix from matrix cache for draw primitive.
##
##  @param[in] _cache Index in matrix cache.
##  @param[in] _num Number of matrices from cache.
##
##

proc encoder_set_transform_cached*(this: ptr encoder_t; cache: uint32;
                                       num: uint16) {.cdecl,
    importc: "bgfx_encoder_set_transform_cached", dynlib: lib.}
## *
##  Reserve matrices in internal matrix cache.
##  @attention Pointer returned can be modifed until `bgfx::frame` is called.
##
##  @param[out] _transform Pointer to `Transform` structure.
##  @param[in] _num Number of matrices.
##
##  @returns Index in matrix cache.
##
##

proc encoder_alloc_transform*(this: ptr encoder_t;
                                  transform: ptr transform_t; num: uint16): uint32 {.
    cdecl, importc: "bgfx_encoder_alloc_transform", dynlib: lib.}
## *
##  Set shader uniform parameter for draw primitive.
##
##  @param[in] _handle Uniform.
##  @param[in] _value Pointer to uniform data.
##  @param[in] _num Number of elements. Passing `UINT16_MAX` will
##   use the _num passed on uniform creation.
##
##

proc encoder_set_uniform*(this: ptr encoder_t;
                              handle: uniform_handle_t; value: pointer;
                              num: uint16) {.cdecl,
    importc: "bgfx_encoder_set_uniform", dynlib: lib.}
## *
##  Set index buffer for draw primitive.
##
##  @param[in] _handle Index buffer.
##  @param[in] _firstIndex First index to render.
##  @param[in] _numIndices Number of indices to render.
##
##

proc encoder_set_index_buffer*(this: ptr encoder_t;
                                   handle: index_buffer_handle_t;
                                   firstIndex: uint32; numIndices: uint32) {.
    cdecl, importc: "bgfx_encoder_set_index_buffer", dynlib: lib.}
## *
##  Set index buffer for draw primitive.
##
##  @param[in] _handle Dynamic index buffer.
##  @param[in] _firstIndex First index to render.
##  @param[in] _numIndices Number of indices to render.
##
##

proc encoder_set_dynamic_index_buffer*(this: ptr encoder_t;
    handle: dynamic_index_buffer_handle_t; firstIndex: uint32;
    numIndices: uint32) {.cdecl,
                           importc: "bgfx_encoder_set_dynamic_index_buffer",
                           dynlib: lib.}
## *
##  Set index buffer for draw primitive.
##
##  @param[in] _tib Transient index buffer.
##  @param[in] _firstIndex First index to render.
##  @param[in] _numIndices Number of indices to render.
##
##

proc encoder_set_transient_index_buffer*(this: ptr encoder_t;
    tib: ptr transient_index_buffer_t; firstIndex: uint32;
    numIndices: uint32) {.cdecl,
                           importc: "bgfx_encoder_set_transient_index_buffer",
                           dynlib: lib.}
## *
##  Set vertex buffer for draw primitive.
##
##  @param[in] _stream Vertex stream.
##  @param[in] _handle Vertex buffer.
##  @param[in] _startVertex First vertex to render.
##  @param[in] _numVertices Number of vertices to render.
##
##

proc encoder_set_vertex_buffer*(this: ptr encoder_t; stream: uint8_t;
                                    handle: vertex_buffer_handle_t;
                                    startVertex: uint32; numVertices: uint32) {.
    cdecl, importc: "bgfx_encoder_set_vertex_buffer", dynlib: lib.}
## *
##  Set vertex buffer for draw primitive.
##
##  @param[in] _stream Vertex stream.
##  @param[in] _handle Dynamic vertex buffer.
##  @param[in] _startVertex First vertex to render.
##  @param[in] _numVertices Number of vertices to render.
##
##

proc encoder_set_dynamic_vertex_buffer*(this: ptr encoder_t;
    stream: uint8_t; handle: dynamic_vertex_buffer_handle_t;
    startVertex: uint32; numVertices: uint32) {.cdecl,
    importc: "bgfx_encoder_set_dynamic_vertex_buffer", dynlib: lib.}
## *
##  Set vertex buffer for draw primitive.
##
##  @param[in] _stream Vertex stream.
##  @param[in] _tvb Transient vertex buffer.
##  @param[in] _startVertex First vertex to render.
##  @param[in] _numVertices Number of vertices to render.
##
##

proc encoder_set_transient_vertex_buffer*(this: ptr encoder_t;
    stream: uint8_t; tvb: ptr transient_vertex_buffer_t;
    startVertex: uint32; numVertices: uint32) {.cdecl,
    importc: "bgfx_encoder_set_transient_vertex_buffer", dynlib: lib.}
## *
##  Set number of vertices for auto generated vertices use in conjuction
##  with gl_VertexID.
##  @attention Availability depends on: `CAPS_VERTEX_ID`.
##
##  @param[in] _numVertices Number of vertices.
##
##

proc encoder_set_vertex_count*(this: ptr encoder_t;
                                   numVertices: uint32) {.cdecl,
    importc: "bgfx_encoder_set_vertex_count", dynlib: lib.}
## *
##  Set instance data buffer for draw primitive.
##
##  @param[in] _idb Transient instance data buffer.
##  @param[in] _start First instance data.
##  @param[in] _num Number of data instances.
##
##

proc encoder_set_instance_data_buffer*(this: ptr encoder_t;
    idb: ptr instance_data_buffer_t; start: uint32; num: uint32) {.cdecl,
    importc: "bgfx_encoder_set_instance_data_buffer", dynlib: lib.}
## *
##  Set instance data buffer for draw primitive.
##
##  @param[in] _handle Vertex buffer.
##  @param[in] _startVertex First instance data.
##  @param[in] _num Number of data instances.
##   Set instance data buffer for draw primitive.
##
##

proc encoder_set_instance_data_from_vertex_buffer*(
    this: ptr encoder_t; handle: vertex_buffer_handle_t;
    startVertex: uint32; num: uint32) {.cdecl,
    importc: "bgfx_encoder_set_instance_data_from_vertex_buffer", dynlib: lib.}
## *
##  Set instance data buffer for draw primitive.
##
##  @param[in] _handle Dynamic vertex buffer.
##  @param[in] _startVertex First instance data.
##  @param[in] _num Number of data instances.
##
##

proc encoder_set_instance_data_from_dynamic_vertex_buffer*(
    this: ptr encoder_t; handle: dynamic_vertex_buffer_handle_t;
    startVertex: uint32; num: uint32) {.cdecl,
    importc: "bgfx_encoder_set_instance_data_from_dynamic_vertex_buffer",
    dynlib: lib.}
## *
##  Set number of instances for auto generated instances use in conjuction
##  with gl_InstanceID.
##  @attention Availability depends on: `CAPS_VERTEX_ID`.
##
##  @param[in] _numInstances
##
##

proc encoder_set_instance_count*(this: ptr encoder_t;
                                     numInstances: uint32) {.cdecl,
    importc: "bgfx_encoder_set_instance_count", dynlib: lib.}
## *
##  Set texture stage for draw primitive.
##
##  @param[in] _stage Texture unit.
##  @param[in] _sampler Program sampler.
##  @param[in] _handle Texture handle.
##  @param[in] _flags Texture sampling mode. Default value UINT32_MAX uses
##     texture sampling settings from the texture.
##     - `SAMPLER_[U/V/W]_[MIRROR/CLAMP]` - Mirror or clamp to edge wrap
##       mode.
##     - `SAMPLER_[MIN/MAG/MIP]_[POINT/ANISOTROPIC]` - Point or anisotropic
##       sampling.
##
##

proc encoder_set_texture*(this: ptr encoder_t; stage: uint8_t;
                              sampler: uniform_handle_t;
                              handle: texture_handle_t; flags: uint32) {.
    cdecl, importc: "bgfx_encoder_set_texture", dynlib: lib.}
## *
##  Submit an empty primitive for rendering. Uniforms and draw state
##  will be applied but no geometry will be submitted.
##  @remark
##    These empty draw calls will sort before ordinary draw calls.
##
##  @param[in] _id View id.
##
##

proc encoder_touch*(this: ptr encoder_t; id: view_id_t) {.cdecl,
    importc: "bgfx_encoder_touch", dynlib: lib.}
## *
##  Submit primitive for rendering.
##
##  @param[in] _id View id.
##  @param[in] _program Program.
##  @param[in] _depth Depth for sorting.
##  @param[in] _preserveState Preserve internal draw state for next draw call submit.
##
##

proc encoder_submit*(this: ptr encoder_t; id: view_id_t;
                         program: program_handle_t; depth: uint32;
                         preserveState: bool) {.cdecl,
    importc: "bgfx_encoder_submit", dynlib: lib.}
## *
##  Submit primitive with occlusion query for rendering.
##
##  @param[in] _id View id.
##  @param[in] _program Program.
##  @param[in] _occlusionQuery Occlusion query.
##  @param[in] _depth Depth for sorting.
##  @param[in] _preserveState Preserve internal draw state for next draw call submit.
##
##

proc encoder_submit_occlusion_query*(this: ptr encoder_t;
    id: view_id_t; program: program_handle_t;
    occlusionQuery: occlusion_query_handle_t; depth: uint32;
    preserveState: bool) {.cdecl, importc: "bgfx_encoder_submit_occlusion_query",
                          dynlib: lib.}
## *
##  Submit primitive for rendering with index and instance data info from
##  indirect buffer.
##
##  @param[in] _id View id.
##  @param[in] _program Program.
##  @param[in] _indirectHandle Indirect buffer.
##  @param[in] _start First element in indirect buffer.
##  @param[in] _num Number of dispatches.
##  @param[in] _depth Depth for sorting.
##  @param[in] _preserveState Preserve internal draw state for next draw call submit.
##
##

proc encoder_submit_indirect*(this: ptr encoder_t; id: view_id_t;
                                  program: program_handle_t; indirectHandle: indirect_buffer_handle_t;
                                  start: uint16; num: uint16;
                                  depth: uint32; preserveState: bool) {.cdecl,
    importc: "bgfx_encoder_submit_indirect", dynlib: lib.}
## *
##  Set compute index buffer.
##
##  @param[in] _stage Compute stage.
##  @param[in] _handle Index buffer handle.
##  @param[in] _access Buffer access. See `Access::Enum`.
##
##

proc encoder_set_compute_index_buffer*(this: ptr encoder_t;
    stage: uint8_t; handle: index_buffer_handle_t; access: access_t) {.
    cdecl, importc: "bgfx_encoder_set_compute_index_buffer", dynlib: lib.}
## *
##  Set compute vertex buffer.
##
##  @param[in] _stage Compute stage.
##  @param[in] _handle Vertex buffer handle.
##  @param[in] _access Buffer access. See `Access::Enum`.
##
##

proc encoder_set_compute_vertex_buffer*(this: ptr encoder_t;
    stage: uint8_t; handle: vertex_buffer_handle_t; access: access_t) {.
    cdecl, importc: "bgfx_encoder_set_compute_vertex_buffer", dynlib: lib.}
## *
##  Set compute dynamic index buffer.
##
##  @param[in] _stage Compute stage.
##  @param[in] _handle Dynamic index buffer handle.
##  @param[in] _access Buffer access. See `Access::Enum`.
##
##

proc encoder_set_compute_dynamic_index_buffer*(this: ptr encoder_t;
    stage: uint8_t; handle: dynamic_index_buffer_handle_t;
    access: access_t) {.cdecl, importc: "bgfx_encoder_set_compute_dynamic_index_buffer",
                            dynlib: lib.}
## *
##  Set compute dynamic vertex buffer.
##
##  @param[in] _stage Compute stage.
##  @param[in] _handle Dynamic vertex buffer handle.
##  @param[in] _access Buffer access. See `Access::Enum`.
##
##

proc encoder_set_compute_dynamic_vertex_buffer*(this: ptr encoder_t;
    stage: uint8_t; handle: dynamic_vertex_buffer_handle_t;
    access: access_t) {.cdecl, importc: "bgfx_encoder_set_compute_dynamic_vertex_buffer",
                            dynlib: lib.}
## *
##  Set compute indirect buffer.
##
##  @param[in] _stage Compute stage.
##  @param[in] _handle Indirect buffer handle.
##  @param[in] _access Buffer access. See `Access::Enum`.
##
##

proc encoder_set_compute_indirect_buffer*(this: ptr encoder_t;
    stage: uint8_t; handle: indirect_buffer_handle_t; access: access_t) {.
    cdecl, importc: "bgfx_encoder_set_compute_indirect_buffer", dynlib: lib.}
## *
##  Set compute image from texture.
##
##  @param[in] _stage Compute stage.
##  @param[in] _handle Texture handle.
##  @param[in] _mip Mip level.
##  @param[in] _access Image access. See `Access::Enum`.
##  @param[in] _format Texture format. See: `TextureFormat::Enum`.
##
##

proc encoder_set_image*(this: ptr encoder_t; stage: uint8_t;
                            handle: texture_handle_t; mip: uint8_t;
                            access: access_t; format: texture_format_t) {.
    cdecl, importc: "bgfx_encoder_set_image", dynlib: lib.}
## *
##  Dispatch compute.
##
##  @param[in] _id View id.
##  @param[in] _program Compute program.
##  @param[in] _numX Number of groups X.
##  @param[in] _numY Number of groups Y.
##  @param[in] _numZ Number of groups Z.
##
##

proc encoder_dispatch*(this: ptr encoder_t; id: view_id_t;
                           program: program_handle_t; numX: uint32;
                           numY: uint32; numZ: uint32) {.cdecl,
    importc: "bgfx_encoder_dispatch", dynlib: lib.}
## *
##  Dispatch compute indirect.
##
##  @param[in] _id View id.
##  @param[in] _program Compute program.
##  @param[in] _indirectHandle Indirect buffer.
##  @param[in] _start First element in indirect buffer.
##  @param[in] _num Number of dispatches.
##
##

proc encoder_dispatch_indirect*(this: ptr encoder_t; id: view_id_t;
                                    program: program_handle_t;
    indirectHandle: indirect_buffer_handle_t; start: uint16; num: uint16) {.
    cdecl, importc: "bgfx_encoder_dispatch_indirect", dynlib: lib.}
## *
##  Discard all previously set state for draw or compute call.
##
##

proc encoder_discard*(this: ptr encoder_t) {.cdecl,
    importc: "bgfx_encoder_discard", dynlib: lib.}
## *
##  Blit 2D texture region between two 2D textures.
##  @attention Destination texture must be created with `TEXTURE_BLIT_DST` flag.
##  @attention Availability depends on: `CAPS_TEXTURE_BLIT`.
##
##  @param[in] _id View id.
##  @param[in] _dst Destination texture handle.
##  @param[in] _dstMip Destination texture mip level.
##  @param[in] _dstX Destination texture X position.
##  @param[in] _dstY Destination texture Y position.
##  @param[in] _dstZ If texture is 2D this argument should be 0. If destination texture is cube
##   this argument represents destination texture cube face. For 3D texture this argument
##   represents destination texture Z position.
##  @param[in] _src Source texture handle.
##  @param[in] _srcMip Source texture mip level.
##  @param[in] _srcX Source texture X position.
##  @param[in] _srcY Source texture Y position.
##  @param[in] _srcZ If texture is 2D this argument should be 0. If source texture is cube
##   this argument represents source texture cube face. For 3D texture this argument
##   represents source texture Z position.
##  @param[in] _width Width of region.
##  @param[in] _height Height of region.
##  @param[in] _depth If texture is 3D this argument represents depth of region, otherwise it's
##   unused.
##
##

proc encoder_blit*(this: ptr encoder_t; id: view_id_t;
                       dst: texture_handle_t; dstMip: uint8_t;
                       dstX: uint16; dstY: uint16; dstZ: uint16;
                       src: texture_handle_t; srcMip: uint8_t;
                       srcX: uint16; srcY: uint16; srcZ: uint16;
                       width: uint16; height: uint16; depth: uint16) {.cdecl,
    importc: "bgfx_encoder_blit", dynlib: lib.}
## *
##  Request screen shot of window back buffer.
##  @remarks
##    `bgfx::CallbackI::screenShot` must be implemented.
##  @attention Frame buffer handle must be created with OS' target native window handle.
##
##  @param[in] _handle Frame buffer handle. If handle is `INVALID_HANDLE` request will be
##   made for main window back buffer.
##  @param[in] _filePath Will be passed to `bgfx::CallbackI::screenShot` callback.
##
##

proc request_screen_shot*(handle: frame_buffer_handle_t;
                              filePath: cstring) {.cdecl,
    importc: "bgfx_request_screen_shot", dynlib: lib.}
## *
##  Render frame.
##  @attention `bgfx::renderFrame` is blocking call. It waits for
##    `bgfx::frame` to be called from API thread to process frame.
##    If timeout value is passed call will timeout and return even
##    if `bgfx::frame` is not called.
##  @warning This call should be only used on platforms that don't
##    allow creating separate rendering thread. If it is called before
##    to bgfx::init, render thread won't be created by bgfx::init call.
##
##  @param[in] _msecs Timeout in milliseconds.
##
##  @returns Current renderer context state. See: `bgfx::RenderFrame`.
##
##

proc render_frame*(msecs: int32_t): render_frame_t {.cdecl,
    importc: "bgfx_render_frame", dynlib: lib.}
## *
##  Set platform data.
##  @warning Must be called before `bgfx::init`.
##
##  @param[in] _data Platform data.
##
##

proc set_platform_data*(data: ptr platform_data_t) {.cdecl,
    importc: "bgfx_set_platform_data", dynlib: lib.}
## *
##  Get internal data for interop.
##  @attention It's expected you understand some bgfx internals before you
##    use this call.
##  @warning Must be called only on render thread.
##
##

proc get_internal_data*(): ptr internal_data_t {.cdecl,
    importc: "bgfx_get_internal_data", dynlib: lib.}
## *
##  Override internal texture with externally created texture. Previously
##  created internal texture will released.
##  @attention It's expected you understand some bgfx internals before you
##    use this call.
##  @warning Must be called only on render thread.
##
##  @param[in] _handle Texture handle.
##  @param[in] _ptr Native API pointer to texture.
##
##  @returns Native API pointer to texture. If result is 0, texture is not created
##   yet from the main thread.
##
##

proc override_internal_texture_ptr*(handle: texture_handle_t;
                                        ptr: uintptr_t): uintptr_t {.cdecl,
    importc: "bgfx_override_internal_texture_ptr", dynlib: lib.}
## *
##  Override internal texture by creating new texture. Previously created
##  internal texture will released.
##  @attention It's expected you understand some bgfx internals before you
##    use this call.
##  @param[in] _handle Texture handle.
##  @param[in] _width Width.
##  @param[in] _height Height.
##  @param[in] _numMips Number of mip-maps.
##  @param[in] _format Texture format. See: `TextureFormat::Enum`.
##  @param[in] _flags Default texture sampling mode is linear, and wrap mode
##    is repeat.
##    - `TEXTURE_[U/V/W]_[MIRROR/CLAMP]` - Mirror or clamp to edge wrap
##      mode.
##    - `TEXTURE_[MIN/MAG/MIP]_[POINT/ANISOTROPIC]` - Point or anisotropic
##      sampling.
##  @returns Native API pointer to texture. If result is 0, texture is not created yet from the
##    main thread.
##  @warning Must be called only on render thread.
##
##  @param[in] _handle Texture handle.
##  @param[in] _width Width.
##  @param[in] _height Height.
##  @param[in] _numMips Number of mip-maps.
##  @param[in] _format Texture format. See: `TextureFormat::Enum`.
##  @param[in] _flags Texture creation (see `TEXTURE_*`.), and sampler (see `SAMPLER_*`)
##   flags. Default texture sampling mode is linear, and wrap mode is repeat.
##   - `SAMPLER_[U/V/W]_[MIRROR/CLAMP]` - Mirror or clamp to edge wrap
##     mode.
##   - `SAMPLER_[MIN/MAG/MIP]_[POINT/ANISOTROPIC]` - Point or anisotropic
##     sampling.
##
##  @returns Native API pointer to texture. If result is 0, texture is not created
##   yet from the main thread.
##
##

proc override_internal_texture*(handle: texture_handle_t;
                                    width: uint16; height: uint16;
                                    numMips: uint8_t;
                                    format: texture_format_t;
                                    flags: uint64): uintptr_t {.cdecl,
    importc: "bgfx_override_internal_texture", dynlib: lib.}
## *
##  Sets a debug marker. This allows you to group graphics calls together for easy browsing in
##  graphics debugging tools.
##
##  @param[in] _marker Marker string.
##
##

proc set_marker*(marker: cstring) {.cdecl, importc: "bgfx_set_marker",
                                       dynlib: lib.}
## *
##  Set render states for draw primitive.
##  @remarks
##    1. To setup more complex states use:
##       `STATE_ALPHA_REF(_ref)`,
##       `STATE_POINT_SIZE(_size)`,
##       `STATE_BLEND_FUNC(_src, _dst)`,
##       `STATE_BLEND_FUNC_SEPARATE(_srcRGB, _dstRGB, _srcA, _dstA)`,
##       `STATE_BLEND_EQUATION(_equation)`,
##       `STATE_BLEND_EQUATION_SEPARATE(_equationRGB, _equationA)`
##    2. `STATE_BLEND_EQUATION_ADD` is set when no other blend
##       equation is specified.
##
##  @param[in] _state State flags. Default state for primitive type is
##     triangles. See: `STATE_DEFAULT`.
##     - `STATE_DEPTH_TEST_*` - Depth test function.
##     - `STATE_BLEND_*` - See remark 1 about STATE_BLEND_FUNC.
##     - `STATE_BLEND_EQUATION_*` - See remark 2.
##     - `STATE_CULL_*` - Backface culling mode.
##     - `STATE_WRITE_*` - Enable R, G, B, A or Z write.
##     - `STATE_MSAA` - Enable hardware multisample antialiasing.
##     - `STATE_PT_[TRISTRIP/LINES/POINTS]` - Primitive type.
##  @param[in] _rgba Sets blend factor used by `STATE_BLEND_FACTOR` and
##     `STATE_BLEND_INV_FACTOR` blend modes.
##
##

proc set_state*(state: uint64; rgba: uint32) {.cdecl,
    importc: "bgfx_set_state", dynlib: lib.}
## *
##  Set condition for rendering.
##
##  @param[in] _handle Occlusion query handle.
##  @param[in] _visible Render if occlusion query is visible.
##
##

proc set_condition*(handle: occlusion_query_handle_t; visible: bool) {.
    cdecl, importc: "bgfx_set_condition", dynlib: lib.}
## *
##  Set stencil test state.
##
##  @param[in] _fstencil Front stencil state.
##  @param[in] _bstencil Back stencil state. If back is set to `STENCIL_NONE`
##   _fstencil is applied to both front and back facing primitives.
##
##

proc set_stencil*(fstencil: uint32; bstencil: uint32) {.cdecl,
    importc: "bgfx_set_stencil", dynlib: lib.}
## *
##  Set scissor for draw primitive.
##  @remark
##    To scissor for all primitives in view see `bgfx::setViewScissor`.
##
##  @param[in] _x Position x from the left corner of the window.
##  @param[in] _y Position y from the top corner of the window.
##  @param[in] _width Width of view scissor region.
##  @param[in] _height Height of view scissor region.
##
##  @returns Scissor cache index.
##
##

proc set_scissor*(x: uint16; y: uint16; width: uint16; height: uint16): uint16 {.
    cdecl, importc: "bgfx_set_scissor", dynlib: lib.}
## *
##  Set scissor from cache for draw primitive.
##  @remark
##    To scissor for all primitives in view see `bgfx::setViewScissor`.
##
##  @param[in] _cache Index in scissor cache.
##
##

proc set_scissor_cached*(cache: uint16) {.cdecl,
    importc: "bgfx_set_scissor_cached", dynlib: lib.}
## *
##  Set model matrix for draw primitive. If it is not called,
##  the model will be rendered with an identity model matrix.
##
##  @param[in] _mtx Pointer to first matrix in array.
##  @param[in] _num Number of matrices in array.
##
##  @returns Index into matrix cache in case the same model matrix has
##   to be used for other draw primitive call.
##
##

proc set_transform*(mtx: pointer; num: uint16): uint32 {.cdecl,
    importc: "bgfx_set_transform", dynlib: lib.}
## *
##   Set model matrix from matrix cache for draw primitive.
##
##  @param[in] _cache Index in matrix cache.
##  @param[in] _num Number of matrices from cache.
##
##

proc set_transform_cached*(cache: uint32; num: uint16) {.cdecl,
    importc: "bgfx_set_transform_cached", dynlib: lib.}
## *
##  Reserve matrices in internal matrix cache.
##  @attention Pointer returned can be modifed until `bgfx::frame` is called.
##
##  @param[out] _transform Pointer to `Transform` structure.
##  @param[in] _num Number of matrices.
##
##  @returns Index in matrix cache.
##
##

proc alloc_transform*(transform: ptr transform_t; num: uint16): uint32 {.
    cdecl, importc: "bgfx_alloc_transform", dynlib: lib.}
## *
##  Set shader uniform parameter for draw primitive.
##
##  @param[in] _handle Uniform.
##  @param[in] _value Pointer to uniform data.
##  @param[in] _num Number of elements. Passing `UINT16_MAX` will
##   use the _num passed on uniform creation.
##
##

proc set_uniform*(handle: uniform_handle_t; value: pointer;
                      num: uint16) {.cdecl, importc: "bgfx_set_uniform",
                                      dynlib: lib.}
## *
##  Set index buffer for draw primitive.
##
##  @param[in] _handle Index buffer.
##  @param[in] _firstIndex First index to render.
##  @param[in] _numIndices Number of indices to render.
##
##

proc set_index_buffer*(handle: index_buffer_handle_t;
                           firstIndex: uint32; numIndices: uint32) {.cdecl,
    importc: "bgfx_set_index_buffer", dynlib: lib.}
## *
##  Set index buffer for draw primitive.
##
##  @param[in] _handle Dynamic index buffer.
##  @param[in] _firstIndex First index to render.
##  @param[in] _numIndices Number of indices to render.
##
##

proc set_dynamic_index_buffer*(handle: dynamic_index_buffer_handle_t;
                                   firstIndex: uint32; numIndices: uint32) {.
    cdecl, importc: "bgfx_set_dynamic_index_buffer", dynlib: lib.}
## *
##  Set index buffer for draw primitive.
##
##  @param[in] _tib Transient index buffer.
##  @param[in] _firstIndex First index to render.
##  @param[in] _numIndices Number of indices to render.
##
##

proc set_transient_index_buffer*(tib: ptr transient_index_buffer_t;
                                     firstIndex: uint32; numIndices: uint32) {.
    cdecl, importc: "bgfx_set_transient_index_buffer", dynlib: lib.}
## *
##  Set vertex buffer for draw primitive.
##
##  @param[in] _stream Vertex stream.
##  @param[in] _handle Vertex buffer.
##  @param[in] _startVertex First vertex to render.
##  @param[in] _numVertices Number of vertices to render.
##
##

proc set_vertex_buffer*(stream: uint8_t;
                            handle: vertex_buffer_handle_t;
                            startVertex: uint32; numVertices: uint32) {.cdecl,
    importc: "bgfx_set_vertex_buffer", dynlib: lib.}
## *
##  Set vertex buffer for draw primitive.
##
##  @param[in] _stream Vertex stream.
##  @param[in] _handle Dynamic vertex buffer.
##  @param[in] _startVertex First vertex to render.
##  @param[in] _numVertices Number of vertices to render.
##
##

proc set_dynamic_vertex_buffer*(stream: uint8_t; handle: dynamic_vertex_buffer_handle_t;
                                    startVertex: uint32; numVertices: uint32) {.
    cdecl, importc: "bgfx_set_dynamic_vertex_buffer", dynlib: lib.}
## *
##  Set vertex buffer for draw primitive.
##
##  @param[in] _stream Vertex stream.
##  @param[in] _tvb Transient vertex buffer.
##  @param[in] _startVertex First vertex to render.
##  @param[in] _numVertices Number of vertices to render.
##
##

proc set_transient_vertex_buffer*(stream: uint8_t;
                                      tvb: ptr transient_vertex_buffer_t;
                                      startVertex: uint32;
                                      numVertices: uint32) {.cdecl,
    importc: "bgfx_set_transient_vertex_buffer", dynlib: lib.}
## *
##  Set number of vertices for auto generated vertices use in conjuction
##  with gl_VertexID.
##  @attention Availability depends on: `CAPS_VERTEX_ID`.
##
##  @param[in] _numVertices Number of vertices.
##
##

proc set_vertex_count*(numVertices: uint32) {.cdecl,
    importc: "bgfx_set_vertex_count", dynlib: lib.}
## *
##  Set instance data buffer for draw primitive.
##
##  @param[in] _idb Transient instance data buffer.
##  @param[in] _start First instance data.
##  @param[in] _num Number of data instances.
##
##

proc set_instance_data_buffer*(idb: ptr instance_data_buffer_t;
                                   start: uint32; num: uint32) {.cdecl,
    importc: "bgfx_set_instance_data_buffer", dynlib: lib.}
## *
##  Set instance data buffer for draw primitive.
##
##  @param[in] _handle Vertex buffer.
##  @param[in] _startVertex First instance data.
##  @param[in] _num Number of data instances.
##   Set instance data buffer for draw primitive.
##
##

proc set_instance_data_from_vertex_buffer*(
    handle: vertex_buffer_handle_t; startVertex: uint32; num: uint32) {.
    cdecl, importc: "bgfx_set_instance_data_from_vertex_buffer", dynlib: lib.}
## *
##  Set instance data buffer for draw primitive.
##
##  @param[in] _handle Dynamic vertex buffer.
##  @param[in] _startVertex First instance data.
##  @param[in] _num Number of data instances.
##
##

proc set_instance_data_from_dynamic_vertex_buffer*(
    handle: dynamic_vertex_buffer_handle_t; startVertex: uint32;
    num: uint32) {.cdecl, importc: "bgfx_set_instance_data_from_dynamic_vertex_buffer",
                    dynlib: lib.}
## *
##  Set number of instances for auto generated instances use in conjuction
##  with gl_InstanceID.
##  @attention Availability depends on: `CAPS_VERTEX_ID`.
##
##  @param[in] _numInstances
##
##

proc set_instance_count*(numInstances: uint32) {.cdecl,
    importc: "bgfx_set_instance_count", dynlib: lib.}
## *
##  Set texture stage for draw primitive.
##
##  @param[in] _stage Texture unit.
##  @param[in] _sampler Program sampler.
##  @param[in] _handle Texture handle.
##  @param[in] _flags Texture sampling mode. Default value UINT32_MAX uses
##     texture sampling settings from the texture.
##     - `SAMPLER_[U/V/W]_[MIRROR/CLAMP]` - Mirror or clamp to edge wrap
##       mode.
##     - `SAMPLER_[MIN/MAG/MIP]_[POINT/ANISOTROPIC]` - Point or anisotropic
##       sampling.
##
##

proc set_texture*(stage: uint8_t; sampler: uniform_handle_t;
                      handle: texture_handle_t; flags: uint32) {.cdecl,
    importc: "bgfx_set_texture", dynlib: lib.}
## *
##  Submit an empty primitive for rendering. Uniforms and draw state
##  will be applied but no geometry will be submitted.
##  @remark
##    These empty draw calls will sort before ordinary draw calls.
##
##  @param[in] _id View id.
##
##

proc touch*(id: view_id_t) {.cdecl, importc: "bgfx_touch", dynlib: lib.}
## *
##  Submit primitive for rendering.
##
##  @param[in] _id View id.
##  @param[in] _program Program.
##  @param[in] _depth Depth for sorting.
##  @param[in] _preserveState Preserve internal draw state for next draw call submit.
##
##

proc submit*(id: view_id_t; program: program_handle_t;
                 depth: uint32; preserveState: bool) {.cdecl,
    importc: "bgfx_submit", dynlib: lib.}
## *
##  Submit primitive with occlusion query for rendering.
##
##  @param[in] _id View id.
##  @param[in] _program Program.
##  @param[in] _occlusionQuery Occlusion query.
##  @param[in] _depth Depth for sorting.
##  @param[in] _preserveState Preserve internal draw state for next draw call submit.
##
##

proc submit_occlusion_query*(id: view_id_t;
                                 program: program_handle_t; occlusionQuery: occlusion_query_handle_t;
                                 depth: uint32; preserveState: bool) {.cdecl,
    importc: "bgfx_submit_occlusion_query", dynlib: lib.}
## *
##  Submit primitive for rendering with index and instance data info from
##  indirect buffer.
##
##  @param[in] _id View id.
##  @param[in] _program Program.
##  @param[in] _indirectHandle Indirect buffer.
##  @param[in] _start First element in indirect buffer.
##  @param[in] _num Number of dispatches.
##  @param[in] _depth Depth for sorting.
##  @param[in] _preserveState Preserve internal draw state for next draw call submit.
##
##

proc submit_indirect*(id: view_id_t; program: program_handle_t;
                          indirectHandle: indirect_buffer_handle_t;
                          start: uint16; num: uint16; depth: uint32;
                          preserveState: bool) {.cdecl,
    importc: "bgfx_submit_indirect", dynlib: lib.}
## *
##  Set compute index buffer.
##
##  @param[in] _stage Compute stage.
##  @param[in] _handle Index buffer handle.
##  @param[in] _access Buffer access. See `Access::Enum`.
##
##

proc set_compute_index_buffer*(stage: uint8_t;
                                   handle: index_buffer_handle_t;
                                   access: access_t) {.cdecl,
    importc: "bgfx_set_compute_index_buffer", dynlib: lib.}
## *
##  Set compute vertex buffer.
##
##  @param[in] _stage Compute stage.
##  @param[in] _handle Vertex buffer handle.
##  @param[in] _access Buffer access. See `Access::Enum`.
##
##

proc set_compute_vertex_buffer*(stage: uint8_t;
                                    handle: vertex_buffer_handle_t;
                                    access: access_t) {.cdecl,
    importc: "bgfx_set_compute_vertex_buffer", dynlib: lib.}
## *
##  Set compute dynamic index buffer.
##
##  @param[in] _stage Compute stage.
##  @param[in] _handle Dynamic index buffer handle.
##  @param[in] _access Buffer access. See `Access::Enum`.
##
##

proc set_compute_dynamic_index_buffer*(stage: uint8_t;
    handle: dynamic_index_buffer_handle_t; access: access_t) {.cdecl,
    importc: "bgfx_set_compute_dynamic_index_buffer", dynlib: lib.}
## *
##  Set compute dynamic vertex buffer.
##
##  @param[in] _stage Compute stage.
##  @param[in] _handle Dynamic vertex buffer handle.
##  @param[in] _access Buffer access. See `Access::Enum`.
##
##

proc set_compute_dynamic_vertex_buffer*(stage: uint8_t;
    handle: dynamic_vertex_buffer_handle_t; access: access_t) {.cdecl,
    importc: "bgfx_set_compute_dynamic_vertex_buffer", dynlib: lib.}
## *
##  Set compute indirect buffer.
##
##  @param[in] _stage Compute stage.
##  @param[in] _handle Indirect buffer handle.
##  @param[in] _access Buffer access. See `Access::Enum`.
##
##

proc set_compute_indirect_buffer*(stage: uint8_t;
                                      handle: indirect_buffer_handle_t;
                                      access: access_t) {.cdecl,
    importc: "bgfx_set_compute_indirect_buffer", dynlib: lib.}
## *
##  Set compute image from texture.
##
##  @param[in] _stage Compute stage.
##  @param[in] _handle Texture handle.
##  @param[in] _mip Mip level.
##  @param[in] _access Image access. See `Access::Enum`.
##  @param[in] _format Texture format. See: `TextureFormat::Enum`.
##
##

proc set_image*(stage: uint8_t; handle: texture_handle_t; mip: uint8_t;
                    access: access_t; format: texture_format_t) {.cdecl,
    importc: "bgfx_set_image", dynlib: lib.}
## *
##  Dispatch compute.
##
##  @param[in] _id View id.
##  @param[in] _program Compute program.
##  @param[in] _numX Number of groups X.
##  @param[in] _numY Number of groups Y.
##  @param[in] _numZ Number of groups Z.
##
##

proc dispatch*(id: view_id_t; program: program_handle_t;
                   numX: uint32; numY: uint32; numZ: uint32) {.cdecl,
    importc: "bgfx_dispatch", dynlib: lib.}
## *
##  Dispatch compute indirect.
##
##  @param[in] _id View id.
##  @param[in] _program Compute program.
##  @param[in] _indirectHandle Indirect buffer.
##  @param[in] _start First element in indirect buffer.
##  @param[in] _num Number of dispatches.
##
##

proc dispatch_indirect*(id: view_id_t; program: program_handle_t;
                            indirectHandle: indirect_buffer_handle_t;
                            start: uint16; num: uint16) {.cdecl,
    importc: "bgfx_dispatch_indirect", dynlib: lib.}
## *
##  Discard all previously set state for draw or compute call.
##
##

proc discard*() {.cdecl, importc: "bgfx_discard", dynlib: lib.}
## *
##  Blit 2D texture region between two 2D textures.
##  @attention Destination texture must be created with `TEXTURE_BLIT_DST` flag.
##  @attention Availability depends on: `CAPS_TEXTURE_BLIT`.
##
##  @param[in] _id View id.
##  @param[in] _dst Destination texture handle.
##  @param[in] _dstMip Destination texture mip level.
##  @param[in] _dstX Destination texture X position.
##  @param[in] _dstY Destination texture Y position.
##  @param[in] _dstZ If texture is 2D this argument should be 0. If destination texture is cube
##   this argument represents destination texture cube face. For 3D texture this argument
##   represents destination texture Z position.
##  @param[in] _src Source texture handle.
##  @param[in] _srcMip Source texture mip level.
##  @param[in] _srcX Source texture X position.
##  @param[in] _srcY Source texture Y position.
##  @param[in] _srcZ If texture is 2D this argument should be 0. If source texture is cube
##   this argument represents source texture cube face. For 3D texture this argument
##   represents source texture Z position.
##  @param[in] _width Width of region.
##  @param[in] _height Height of region.
##  @param[in] _depth If texture is 3D this argument represents depth of region, otherwise it's
##   unused.
##
##

proc blit*(id: view_id_t; dst: texture_handle_t; dstMip: uint8_t;
               dstX: uint16; dstY: uint16; dstZ: uint16;
               src: texture_handle_t; srcMip: uint8_t; srcX: uint16;
               srcY: uint16; srcZ: uint16; width: uint16; height: uint16;
               depth: uint16) {.cdecl, importc: "bgfx_blit", dynlib: lib.}

type
  function_id_t* {.size: sizeof(cint).} = enum
    FUNCTION_ID_ATTACHMENT_INIT, FUNCTION_ID_VERTEX_DECL_BEGIN,
    FUNCTION_ID_VERTEX_DECL_ADD, FUNCTION_ID_VERTEX_DECL_DECODE,
    FUNCTION_ID_VERTEX_DECL_HAS, FUNCTION_ID_VERTEX_DECL_SKIP,
    FUNCTION_ID_VERTEX_DECL_END, FUNCTION_ID_VERTEX_PACK,
    FUNCTION_ID_VERTEX_UNPACK, FUNCTION_ID_VERTEX_CONVERT,
    FUNCTION_ID_WELD_VERTICES, FUNCTION_ID_TOPOLOGY_CONVERT,
    FUNCTION_ID_TOPOLOGY_SORT_TRI_LIST,
    FUNCTION_ID_GET_SUPPORTED_RENDERERS, FUNCTION_ID_GET_RENDERER_NAME,
    FUNCTION_ID_INIT_CTOR, FUNCTION_ID_INIT, FUNCTION_ID_SHUTDOWN,
    FUNCTION_ID_RESET, FUNCTION_ID_FRAME,
    FUNCTION_ID_GET_RENDERER_TYPE, FUNCTION_ID_GET_CAPS,
    FUNCTION_ID_GET_STATS, FUNCTION_ID_ALLOC, FUNCTION_ID_COPY,
    FUNCTION_ID_MAKE_REF, FUNCTION_ID_MAKE_REF_RELEASE,
    FUNCTION_ID_SET_DEBUG, FUNCTION_ID_DBG_TEXT_CLEAR,
    FUNCTION_ID_DBG_TEXT_PRINTF, FUNCTION_ID_DBG_TEXT_VPRINTF,
    FUNCTION_ID_DBG_TEXT_IMAGE, FUNCTION_ID_CREATE_INDEX_BUFFER,
    FUNCTION_ID_SET_INDEX_BUFFER_NAME,
    FUNCTION_ID_DESTROY_INDEX_BUFFER, FUNCTION_ID_CREATE_VERTEX_BUFFER,
    FUNCTION_ID_SET_VERTEX_BUFFER_NAME,
    FUNCTION_ID_DESTROY_VERTEX_BUFFER,
    FUNCTION_ID_CREATE_DYNAMIC_INDEX_BUFFER,
    FUNCTION_ID_CREATE_DYNAMIC_INDEX_BUFFER_MEM,
    FUNCTION_ID_UPDATE_DYNAMIC_INDEX_BUFFER,
    FUNCTION_ID_DESTROY_DYNAMIC_INDEX_BUFFER,
    FUNCTION_ID_CREATE_DYNAMIC_VERTEX_BUFFER,
    FUNCTION_ID_CREATE_DYNAMIC_VERTEX_BUFFER_MEM,
    FUNCTION_ID_UPDATE_DYNAMIC_VERTEX_BUFFER,
    FUNCTION_ID_DESTROY_DYNAMIC_VERTEX_BUFFER,
    FUNCTION_ID_GET_AVAIL_TRANSIENT_INDEX_BUFFER,
    FUNCTION_ID_GET_AVAIL_TRANSIENT_VERTEX_BUFFER,
    FUNCTION_ID_GET_AVAIL_INSTANCE_DATA_BUFFER,
    FUNCTION_ID_ALLOC_TRANSIENT_INDEX_BUFFER,
    FUNCTION_ID_ALLOC_TRANSIENT_VERTEX_BUFFER,
    FUNCTION_ID_ALLOC_TRANSIENT_BUFFERS,
    FUNCTION_ID_ALLOC_INSTANCE_DATA_BUFFER,
    FUNCTION_ID_CREATE_INDIRECT_BUFFER,
    FUNCTION_ID_DESTROY_INDIRECT_BUFFER, FUNCTION_ID_CREATE_SHADER,
    FUNCTION_ID_GET_SHADER_UNIFORMS, FUNCTION_ID_SET_SHADER_NAME,
    FUNCTION_ID_DESTROY_SHADER, FUNCTION_ID_CREATE_PROGRAM,
    FUNCTION_ID_CREATE_COMPUTE_PROGRAM, FUNCTION_ID_DESTROY_PROGRAM,
    FUNCTION_ID_IS_TEXTURE_VALID, FUNCTION_ID_CALC_TEXTURE_SIZE,
    FUNCTION_ID_CREATE_TEXTURE, FUNCTION_ID_CREATE_TEXTURE_2D,
    FUNCTION_ID_CREATE_TEXTURE_2D_SCALED,
    FUNCTION_ID_CREATE_TEXTURE_3D, FUNCTION_ID_CREATE_TEXTURE_CUBE,
    FUNCTION_ID_UPDATE_TEXTURE_2D, FUNCTION_ID_UPDATE_TEXTURE_3D,
    FUNCTION_ID_UPDATE_TEXTURE_CUBE, FUNCTION_ID_READ_TEXTURE,
    FUNCTION_ID_SET_TEXTURE_NAME, FUNCTION_ID_GET_DIRECT_ACCESS_PTR,
    FUNCTION_ID_DESTROY_TEXTURE, FUNCTION_ID_CREATE_FRAME_BUFFER,
    FUNCTION_ID_CREATE_FRAME_BUFFER_SCALED,
    FUNCTION_ID_CREATE_FRAME_BUFFER_FROM_HANDLES,
    FUNCTION_ID_CREATE_FRAME_BUFFER_FROM_ATTACHMENT,
    FUNCTION_ID_CREATE_FRAME_BUFFER_FROM_NWH,
    FUNCTION_ID_SET_FRAME_BUFFER_NAME, FUNCTION_ID_GET_TEXTURE,
    FUNCTION_ID_DESTROY_FRAME_BUFFER, FUNCTION_ID_CREATE_UNIFORM,
    FUNCTION_ID_GET_UNIFORM_INFO, FUNCTION_ID_DESTROY_UNIFORM,
    FUNCTION_ID_CREATE_OCCLUSION_QUERY, FUNCTION_ID_GET_RESULT,
    FUNCTION_ID_DESTROY_OCCLUSION_QUERY, FUNCTION_ID_SET_PALETTE_COLOR,
    FUNCTION_ID_SET_PALETTE_COLOR_RGBA8, FUNCTION_ID_SET_VIEW_NAME,
    FUNCTION_ID_SET_VIEW_RECT, FUNCTION_ID_SET_VIEW_RECT_RATIO,
    FUNCTION_ID_SET_VIEW_SCISSOR, FUNCTION_ID_SET_VIEW_CLEAR,
    FUNCTION_ID_SET_VIEW_CLEAR_MRT, FUNCTION_ID_SET_VIEW_MODE,
    FUNCTION_ID_SET_VIEW_FRAME_BUFFER, FUNCTION_ID_SET_VIEW_TRANSFORM,
    FUNCTION_ID_SET_VIEW_ORDER, FUNCTION_ID_ENCODER_BEGIN,
    FUNCTION_ID_ENCODER_END, FUNCTION_ID_ENCODER_SET_MARKER,
    FUNCTION_ID_ENCODER_SET_STATE, FUNCTION_ID_ENCODER_SET_CONDITION,
    FUNCTION_ID_ENCODER_SET_STENCIL, FUNCTION_ID_ENCODER_SET_SCISSOR,
    FUNCTION_ID_ENCODER_SET_SCISSOR_CACHED,
    FUNCTION_ID_ENCODER_SET_TRANSFORM,
    FUNCTION_ID_ENCODER_SET_TRANSFORM_CACHED,
    FUNCTION_ID_ENCODER_ALLOC_TRANSFORM,
    FUNCTION_ID_ENCODER_SET_UNIFORM,
    FUNCTION_ID_ENCODER_SET_INDEX_BUFFER,
    FUNCTION_ID_ENCODER_SET_DYNAMIC_INDEX_BUFFER,
    FUNCTION_ID_ENCODER_SET_TRANSIENT_INDEX_BUFFER,
    FUNCTION_ID_ENCODER_SET_VERTEX_BUFFER,
    FUNCTION_ID_ENCODER_SET_DYNAMIC_VERTEX_BUFFER,
    FUNCTION_ID_ENCODER_SET_TRANSIENT_VERTEX_BUFFER,
    FUNCTION_ID_ENCODER_SET_VERTEX_COUNT,
    FUNCTION_ID_ENCODER_SET_INSTANCE_DATA_BUFFER,
    FUNCTION_ID_ENCODER_SET_INSTANCE_DATA_FROM_VERTEX_BUFFER,
    FUNCTION_ID_ENCODER_SET_INSTANCE_DATA_FROM_DYNAMIC_VERTEX_BUFFER,
    FUNCTION_ID_ENCODER_SET_INSTANCE_COUNT,
    FUNCTION_ID_ENCODER_SET_TEXTURE, FUNCTION_ID_ENCODER_TOUCH,
    FUNCTION_ID_ENCODER_SUBMIT,
    FUNCTION_ID_ENCODER_SUBMIT_OCCLUSION_QUERY,
    FUNCTION_ID_ENCODER_SUBMIT_INDIRECT,
    FUNCTION_ID_ENCODER_SET_COMPUTE_INDEX_BUFFER,
    FUNCTION_ID_ENCODER_SET_COMPUTE_VERTEX_BUFFER,
    FUNCTION_ID_ENCODER_SET_COMPUTE_DYNAMIC_INDEX_BUFFER,
    FUNCTION_ID_ENCODER_SET_COMPUTE_DYNAMIC_VERTEX_BUFFER,
    FUNCTION_ID_ENCODER_SET_COMPUTE_INDIRECT_BUFFER,
    FUNCTION_ID_ENCODER_SET_IMAGE, FUNCTION_ID_ENCODER_DISPATCH,
    FUNCTION_ID_ENCODER_DISPATCH_INDIRECT, FUNCTION_ID_ENCODER_DISCARD,
    FUNCTION_ID_ENCODER_BLIT, FUNCTION_ID_REQUEST_SCREEN_SHOT,
    FUNCTION_ID_RENDER_FRAME, FUNCTION_ID_SET_PLATFORM_DATA,
    FUNCTION_ID_GET_INTERNAL_DATA,
    FUNCTION_ID_OVERRIDE_INTERNAL_TEXTURE_PTR,
    FUNCTION_ID_OVERRIDE_INTERNAL_TEXTURE, FUNCTION_ID_SET_MARKER,
    FUNCTION_ID_SET_STATE, FUNCTION_ID_SET_CONDITION,
    FUNCTION_ID_SET_STENCIL, FUNCTION_ID_SET_SCISSOR,
    FUNCTION_ID_SET_SCISSOR_CACHED, FUNCTION_ID_SET_TRANSFORM,
    FUNCTION_ID_SET_TRANSFORM_CACHED, FUNCTION_ID_ALLOC_TRANSFORM,
    FUNCTION_ID_SET_UNIFORM, FUNCTION_ID_SET_INDEX_BUFFER,
    FUNCTION_ID_SET_DYNAMIC_INDEX_BUFFER,
    FUNCTION_ID_SET_TRANSIENT_INDEX_BUFFER,
    FUNCTION_ID_SET_VERTEX_BUFFER,
    FUNCTION_ID_SET_DYNAMIC_VERTEX_BUFFER,
    FUNCTION_ID_SET_TRANSIENT_VERTEX_BUFFER,
    FUNCTION_ID_SET_VERTEX_COUNT, FUNCTION_ID_SET_INSTANCE_DATA_BUFFER,
    FUNCTION_ID_SET_INSTANCE_DATA_FROM_VERTEX_BUFFER,
    FUNCTION_ID_SET_INSTANCE_DATA_FROM_DYNAMIC_VERTEX_BUFFER,
    FUNCTION_ID_SET_INSTANCE_COUNT, FUNCTION_ID_SET_TEXTURE,
    FUNCTION_ID_TOUCH, FUNCTION_ID_SUBMIT,
    FUNCTION_ID_SUBMIT_OCCLUSION_QUERY, FUNCTION_ID_SUBMIT_INDIRECT,
    FUNCTION_ID_SET_COMPUTE_INDEX_BUFFER,
    FUNCTION_ID_SET_COMPUTE_VERTEX_BUFFER,
    FUNCTION_ID_SET_COMPUTE_DYNAMIC_INDEX_BUFFER,
    FUNCTION_ID_SET_COMPUTE_DYNAMIC_VERTEX_BUFFER,
    FUNCTION_ID_SET_COMPUTE_INDIRECT_BUFFER, FUNCTION_ID_SET_IMAGE,
    FUNCTION_ID_DISPATCH, FUNCTION_ID_DISPATCH_INDIRECT,
    FUNCTION_ID_DISCARD, FUNCTION_ID_BLIT, FUNCTION_ID_COUNT



type
  interface_vtbl* {.bycopy.} = object
    attachment_init*: proc (this: ptr attachment_t;
                          handle: texture_handle_t; access: access_t;
                          layer: uint16; mip: uint16; resolve: uint8_t) {.cdecl.}
    vertex_decl_begin*: proc (this: ptr vertex_decl_t;
                            rendererType: renderer_type_t): ptr vertex_decl_t {.
        cdecl.}
    vertex_decl_add*: proc (this: ptr vertex_decl_t; attrib: attrib_t;
                          num: uint8_t; type: attrib_type_t;
                          normalized: bool; asInt: bool): ptr vertex_decl_t {.
        cdecl.}
    vertex_decl_decode*: proc (this: ptr vertex_decl_t; attrib: attrib_t;
                             num: ptr uint8_t; type: ptr attrib_type_t;
                             normalized: ptr bool; asInt: ptr bool) {.cdecl.}
    vertex_decl_has*: proc (this: ptr vertex_decl_t; attrib: attrib_t): bool {.
        cdecl.}
    vertex_decl_skip*: proc (this: ptr vertex_decl_t; num: uint8_t): ptr vertex_decl_t {.
        cdecl.}
    vertex_decl_end*: proc (this: ptr vertex_decl_t) {.cdecl.}
    vertex_pack*: proc (input: array[4, cfloat]; inputNormalized: bool;
                      attr: attrib_t; decl: ptr vertex_decl_t;
                      data: pointer; index: uint32) {.cdecl.}
    vertex_unpack*: proc (output: array[4, cfloat]; attr: attrib_t;
                        decl: ptr vertex_decl_t; data: pointer;
                        index: uint32) {.cdecl.}
    vertex_convert*: proc (dstDecl: ptr vertex_decl_t; dstData: pointer;
                         srcDecl: ptr vertex_decl_t; srcData: pointer;
                         num: uint32) {.cdecl.}
    weld_vertices*: proc (output: ptr uint16; decl: ptr vertex_decl_t;
                        data: pointer; num: uint16; epsilon: cfloat): uint16 {.
        cdecl.}
    topology_convert*: proc (conversion: topology_convert_t; dst: pointer;
                           dstSize: uint32; indices: pointer;
                           numIndices: uint32; index32: bool): uint32 {.cdecl.}
    topology_sort_tri_list*: proc (sort: topology_sort_t; dst: pointer;
                                 dstSize: uint32; dir: array[3, cfloat];
                                 pos: array[3, cfloat]; vertices: pointer;
                                 stride: uint32; indices: pointer;
                                 numIndices: uint32; index32: bool) {.cdecl.}
    get_supported_renderers*: proc (max: uint8_t; enum: ptr renderer_type_t): uint8_t {.
        cdecl.}
    get_renderer_name*: proc (type: renderer_type_t): cstring {.cdecl.}
    init_ctor*: proc (init: ptr init_t) {.cdecl.}
    init*: proc (init: ptr init_t): bool {.cdecl.}
    shutdown*: proc () {.cdecl.}
    reset*: proc (width: uint32; height: uint32; flags: uint32;
                format: texture_format_t) {.cdecl.}
    frame*: proc (capture: bool): uint32 {.cdecl.}
    get_renderer_type*: proc (): renderer_type_t {.cdecl.}
    get_caps*: proc (): ptr caps_t {.cdecl.}
    get_stats*: proc (): ptr stats_t {.cdecl.}
    alloc*: proc (size: uint32): ptr memory_t {.cdecl.}
    copy*: proc (data: pointer; size: uint32): ptr memory_t {.cdecl.}
    make_ref*: proc (data: pointer; size: uint32): ptr memory_t {.cdecl.}
    make_ref_release*: proc (data: pointer; size: uint32;
                           releaseFn: release_fn_t; userData: pointer): ptr memory_t {.
        cdecl.}
    set_debug*: proc (debug: uint32) {.cdecl.}
    dbg_text_clear*: proc (attr: uint8_t; small: bool) {.cdecl.}
    dbg_text_printf*: proc (x: uint16; y: uint16; attr: uint8_t; format: cstring) {.
        cdecl, varargs.}
    dbg_text_vprintf*: proc (x: uint16; y: uint16; attr: uint8_t;
                           format: cstring; argList: va_list) {.cdecl.}
    dbg_text_image*: proc (x: uint16; y: uint16; width: uint16;
                         height: uint16; data: pointer; pitch: uint16) {.cdecl.}
    create_index_buffer*: proc (mem: ptr memory_t; flags: uint16): index_buffer_handle_t {.
        cdecl.}
    set_index_buffer_name*: proc (handle: index_buffer_handle_t;
                                name: cstring; len: int32_t) {.cdecl.}
    destroy_index_buffer*: proc (handle: index_buffer_handle_t) {.cdecl.}
    create_vertex_buffer*: proc (mem: ptr memory_t;
                               decl: ptr vertex_decl_t; flags: uint16): vertex_buffer_handle_t {.
        cdecl.}
    set_vertex_buffer_name*: proc (handle: vertex_buffer_handle_t;
                                 name: cstring; len: int32_t) {.cdecl.}
    destroy_vertex_buffer*: proc (handle: vertex_buffer_handle_t) {.cdecl.}
    create_dynamic_index_buffer*: proc (num: uint32; flags: uint16): dynamic_index_buffer_handle_t {.
        cdecl.}
    create_dynamic_index_buffer_mem*: proc (mem: ptr memory_t; flags: uint16): dynamic_index_buffer_handle_t {.
        cdecl.}
    update_dynamic_index_buffer*: proc (handle: dynamic_index_buffer_handle_t;
                                      startIndex: uint32;
                                      mem: ptr memory_t) {.cdecl.}
    destroy_dynamic_index_buffer*: proc (handle: dynamic_index_buffer_handle_t) {.
        cdecl.}
    create_dynamic_vertex_buffer*: proc (num: uint32;
                                       decl: ptr vertex_decl_t;
                                       flags: uint16): dynamic_vertex_buffer_handle_t {.
        cdecl.}
    create_dynamic_vertex_buffer_mem*: proc (mem: ptr memory_t;
        decl: ptr vertex_decl_t; flags: uint16): dynamic_vertex_buffer_handle_t {.
        cdecl.}
    update_dynamic_vertex_buffer*: proc (handle: dynamic_vertex_buffer_handle_t;
                                       startVertex: uint32;
                                       mem: ptr memory_t) {.cdecl.}
    destroy_dynamic_vertex_buffer*: proc (handle: dynamic_vertex_buffer_handle_t) {.
        cdecl.}
    get_avail_transient_index_buffer*: proc (num: uint32): uint32 {.cdecl.}
    get_avail_transient_vertex_buffer*: proc (num: uint32;
        decl: ptr vertex_decl_t): uint32 {.cdecl.}
    get_avail_instance_data_buffer*: proc (num: uint32; stride: uint16): uint32 {.
        cdecl.}
    alloc_transient_index_buffer*: proc (tib: ptr transient_index_buffer_t;
                                       num: uint32) {.cdecl.}
    alloc_transient_vertex_buffer*: proc (tvb: ptr transient_vertex_buffer_t;
                                        num: uint32;
                                        decl: ptr vertex_decl_t) {.cdecl.}
    alloc_transient_buffers*: proc (tvb: ptr transient_vertex_buffer_t;
                                  decl: ptr vertex_decl_t;
                                  numVertices: uint32;
                                  tib: ptr transient_index_buffer_t;
                                  numIndices: uint32): bool {.cdecl.}
    alloc_instance_data_buffer*: proc (idb: ptr instance_data_buffer_t;
                                     num: uint32; stride: uint16) {.cdecl.}
    create_indirect_buffer*: proc (num: uint32): indirect_buffer_handle_t {.
        cdecl.}
    destroy_indirect_buffer*: proc (handle: indirect_buffer_handle_t) {.cdecl.}
    create_shader*: proc (mem: ptr memory_t): shader_handle_t {.cdecl.}
    get_shader_uniforms*: proc (handle: shader_handle_t;
                              uniforms: ptr uniform_handle_t; max: uint16): uint16 {.
        cdecl.}
    set_shader_name*: proc (handle: shader_handle_t; name: cstring;
                          len: int32_t) {.cdecl.}
    destroy_shader*: proc (handle: shader_handle_t) {.cdecl.}
    create_program*: proc (vsh: shader_handle_t; fsh: shader_handle_t;
                         destroyShaders: bool): program_handle_t {.cdecl.}
    create_compute_program*: proc (csh: shader_handle_t; destroyShaders: bool): program_handle_t {.
        cdecl.}
    destroy_program*: proc (handle: program_handle_t) {.cdecl.}
    is_texture_valid*: proc (depth: uint16; cubeMap: bool; numLayers: uint16;
                           format: texture_format_t; flags: uint64): bool {.
        cdecl.}
    calc_texture_size*: proc (info: ptr texture_info_t; width: uint16;
                            height: uint16; depth: uint16; cubeMap: bool;
                            hasMips: bool; numLayers: uint16;
                            format: texture_format_t) {.cdecl.}
    create_texture*: proc (mem: ptr memory_t; flags: uint64; skip: uint8_t;
                         info: ptr texture_info_t): texture_handle_t {.
        cdecl.}
    create_texture_2d*: proc (width: uint16; height: uint16; hasMips: bool;
                            numLayers: uint16; format: texture_format_t;
                            flags: uint64; mem: ptr memory_t): texture_handle_t {.
        cdecl.}
    create_texture_2d_scaled*: proc (ratio: backbuffer_ratio_t;
                                   hasMips: bool; numLayers: uint16;
                                   format: texture_format_t;
                                   flags: uint64): texture_handle_t {.cdecl.}
    create_texture_3d*: proc (width: uint16; height: uint16; depth: uint16;
                            hasMips: bool; format: texture_format_t;
                            flags: uint64; mem: ptr memory_t): texture_handle_t {.
        cdecl.}
    create_texture_cube*: proc (size: uint16; hasMips: bool; numLayers: uint16;
                              format: texture_format_t; flags: uint64;
                              mem: ptr memory_t): texture_handle_t {.
        cdecl.}
    update_texture_2d*: proc (handle: texture_handle_t; layer: uint16;
                            mip: uint8_t; x: uint16; y: uint16;
                            width: uint16; height: uint16;
                            mem: ptr memory_t; pitch: uint16) {.cdecl.}
    update_texture_3d*: proc (handle: texture_handle_t; mip: uint8_t;
                            x: uint16; y: uint16; z: uint16;
                            width: uint16; height: uint16; depth: uint16;
                            mem: ptr memory_t) {.cdecl.}
    update_texture_cube*: proc (handle: texture_handle_t; layer: uint16;
                              side: uint8_t; mip: uint8_t; x: uint16;
                              y: uint16; width: uint16; height: uint16;
                              mem: ptr memory_t; pitch: uint16) {.cdecl.}
    read_texture*: proc (handle: texture_handle_t; data: pointer; mip: uint8_t): uint32 {.
        cdecl.}
    set_texture_name*: proc (handle: texture_handle_t; name: cstring;
                           len: int32_t) {.cdecl.}
    get_direct_access_ptr*: proc (handle: texture_handle_t): pointer {.cdecl.}
    destroy_texture*: proc (handle: texture_handle_t) {.cdecl.}
    create_frame_buffer*: proc (width: uint16; height: uint16;
                              format: texture_format_t;
                              textureFlags: uint64): frame_buffer_handle_t {.
        cdecl.}
    create_frame_buffer_scaled*: proc (ratio: backbuffer_ratio_t;
                                     format: texture_format_t;
                                     textureFlags: uint64): frame_buffer_handle_t {.
        cdecl.}
    create_frame_buffer_from_handles*: proc (num: uint8_t;
        handles: ptr texture_handle_t; destroyTexture: bool): frame_buffer_handle_t {.
        cdecl.}
    create_frame_buffer_from_attachment*: proc (num: uint8_t;
        attachment: ptr attachment_t; destroyTexture: bool): frame_buffer_handle_t {.
        cdecl.}
    create_frame_buffer_from_nwh*: proc (nwh: pointer; width: uint16;
                                       height: uint16;
                                       format: texture_format_t;
                                       depthFormat: texture_format_t): frame_buffer_handle_t {.
        cdecl.}
    set_frame_buffer_name*: proc (handle: frame_buffer_handle_t;
                                name: cstring; len: int32_t) {.cdecl.}
    get_texture*: proc (handle: frame_buffer_handle_t; attachment: uint8_t): texture_handle_t {.
        cdecl.}
    destroy_frame_buffer*: proc (handle: frame_buffer_handle_t) {.cdecl.}
    create_uniform*: proc (name: cstring; type: uniform_type_t; num: uint16): uniform_handle_t {.
        cdecl.}
    get_uniform_info*: proc (handle: uniform_handle_t;
                           info: ptr uniform_info_t) {.cdecl.}
    destroy_uniform*: proc (handle: uniform_handle_t) {.cdecl.}
    create_occlusion_query*: proc (): occlusion_query_handle_t {.cdecl.}
    get_result*: proc (handle: occlusion_query_handle_t; result: ptr int32_t): occlusion_query_result_t {.
        cdecl.}
    destroy_occlusion_query*: proc (handle: occlusion_query_handle_t) {.cdecl.}
    set_palette_color*: proc (index: uint8_t; rgba: array[4, cfloat]) {.cdecl.}
    set_palette_color_rgba8*: proc (index: uint8_t; rgba: uint32) {.cdecl.}
    set_view_name*: proc (id: view_id_t; name: cstring) {.cdecl.}
    set_view_rect*: proc (id: view_id_t; x: uint16; y: uint16;
                        width: uint16; height: uint16) {.cdecl.}
    set_view_rect_ratio*: proc (id: view_id_t; x: uint16; y: uint16;
                              ratio: backbuffer_ratio_t) {.cdecl.}
    set_view_scissor*: proc (id: view_id_t; x: uint16; y: uint16;
                           width: uint16; height: uint16) {.cdecl.}
    set_view_clear*: proc (id: view_id_t; flags: uint16; rgba: uint32;
                         depth: cfloat; stencil: uint8_t) {.cdecl.}
    set_view_clear_mrt*: proc (id: view_id_t; flags: uint16; depth: cfloat;
                             stencil: uint8_t; c0: uint8_t; c1: uint8_t;
                             c2: uint8_t; c3: uint8_t; c4: uint8_t; c5: uint8_t;
                             c6: uint8_t; c7: uint8_t) {.cdecl.}
    set_view_mode*: proc (id: view_id_t; mode: view_mode_t) {.cdecl.}
    set_view_frame_buffer*: proc (id: view_id_t;
                                handle: frame_buffer_handle_t) {.cdecl.}
    set_view_transform*: proc (id: view_id_t; view: pointer; proj: pointer) {.
        cdecl.}
    set_view_order*: proc (id: view_id_t; num: uint16;
                         order: ptr view_id_t) {.cdecl.}
    encoder_begin*: proc (forThread: bool): ptr encoder_t {.cdecl.}
    encoder_end*: proc (encoder: ptr encoder_t) {.cdecl.}
    encoder_set_marker*: proc (this: ptr encoder_t; marker: cstring) {.cdecl.}
    encoder_set_state*: proc (this: ptr encoder_t; state: uint64;
                            rgba: uint32) {.cdecl.}
    encoder_set_condition*: proc (this: ptr encoder_t;
                                handle: occlusion_query_handle_t;
                                visible: bool) {.cdecl.}
    encoder_set_stencil*: proc (this: ptr encoder_t; fstencil: uint32;
                              bstencil: uint32) {.cdecl.}
    encoder_set_scissor*: proc (this: ptr encoder_t; x: uint16; y: uint16;
                              width: uint16; height: uint16): uint16 {.cdecl.}
    encoder_set_scissor_cached*: proc (this: ptr encoder_t; cache: uint16) {.
        cdecl.}
    encoder_set_transform*: proc (this: ptr encoder_t; mtx: pointer;
                                num: uint16): uint32 {.cdecl.}
    encoder_set_transform_cached*: proc (this: ptr encoder_t; cache: uint32;
                                       num: uint16) {.cdecl.}
    encoder_alloc_transform*: proc (this: ptr encoder_t;
                                  transform: ptr transform_t; num: uint16): uint32 {.
        cdecl.}
    encoder_set_uniform*: proc (this: ptr encoder_t;
                              handle: uniform_handle_t; value: pointer;
                              num: uint16) {.cdecl.}
    encoder_set_index_buffer*: proc (this: ptr encoder_t;
                                   handle: index_buffer_handle_t;
                                   firstIndex: uint32; numIndices: uint32) {.
        cdecl.}
    encoder_set_dynamic_index_buffer*: proc (this: ptr encoder_t;
        handle: dynamic_index_buffer_handle_t; firstIndex: uint32;
        numIndices: uint32) {.cdecl.}
    encoder_set_transient_index_buffer*: proc (this: ptr encoder_t;
        tib: ptr transient_index_buffer_t; firstIndex: uint32;
        numIndices: uint32) {.cdecl.}
    encoder_set_vertex_buffer*: proc (this: ptr encoder_t; stream: uint8_t;
                                    handle: vertex_buffer_handle_t;
                                    startVertex: uint32; numVertices: uint32) {.
        cdecl.}
    encoder_set_dynamic_vertex_buffer*: proc (this: ptr encoder_t;
        stream: uint8_t; handle: dynamic_vertex_buffer_handle_t;
        startVertex: uint32; numVertices: uint32) {.cdecl.}
    encoder_set_transient_vertex_buffer*: proc (this: ptr encoder_t;
        stream: uint8_t; tvb: ptr transient_vertex_buffer_t;
        startVertex: uint32; numVertices: uint32) {.cdecl.}
    encoder_set_vertex_count*: proc (this: ptr encoder_t;
                                   numVertices: uint32) {.cdecl.}
    encoder_set_instance_data_buffer*: proc (this: ptr encoder_t;
        idb: ptr instance_data_buffer_t; start: uint32; num: uint32) {.
        cdecl.}
    encoder_set_instance_data_from_vertex_buffer*: proc (
        this: ptr encoder_t; handle: vertex_buffer_handle_t;
        startVertex: uint32; num: uint32) {.cdecl.}
    encoder_set_instance_data_from_dynamic_vertex_buffer*: proc (
        this: ptr encoder_t; handle: dynamic_vertex_buffer_handle_t;
        startVertex: uint32; num: uint32) {.cdecl.}
    encoder_set_instance_count*: proc (this: ptr encoder_t;
                                     numInstances: uint32) {.cdecl.}
    encoder_set_texture*: proc (this: ptr encoder_t; stage: uint8_t;
                              sampler: uniform_handle_t;
                              handle: texture_handle_t; flags: uint32) {.
        cdecl.}
    encoder_touch*: proc (this: ptr encoder_t; id: view_id_t) {.cdecl.}
    encoder_submit*: proc (this: ptr encoder_t; id: view_id_t;
                         program: program_handle_t; depth: uint32;
                         preserveState: bool) {.cdecl.}
    encoder_submit_occlusion_query*: proc (this: ptr encoder_t;
        id: view_id_t; program: program_handle_t;
        occlusionQuery: occlusion_query_handle_t; depth: uint32;
        preserveState: bool) {.cdecl.}
    encoder_submit_indirect*: proc (this: ptr encoder_t; id: view_id_t;
                                  program: program_handle_t; indirectHandle: indirect_buffer_handle_t;
                                  start: uint16; num: uint16;
                                  depth: uint32; preserveState: bool) {.cdecl.}
    encoder_set_compute_index_buffer*: proc (this: ptr encoder_t;
        stage: uint8_t; handle: index_buffer_handle_t; access: access_t) {.
        cdecl.}
    encoder_set_compute_vertex_buffer*: proc (this: ptr encoder_t;
        stage: uint8_t; handle: vertex_buffer_handle_t;
        access: access_t) {.cdecl.}
    encoder_set_compute_dynamic_index_buffer*: proc (this: ptr encoder_t;
        stage: uint8_t; handle: dynamic_index_buffer_handle_t;
        access: access_t) {.cdecl.}
    encoder_set_compute_dynamic_vertex_buffer*: proc (this: ptr encoder_t;
        stage: uint8_t; handle: dynamic_vertex_buffer_handle_t;
        access: access_t) {.cdecl.}
    encoder_set_compute_indirect_buffer*: proc (this: ptr encoder_t;
        stage: uint8_t; handle: indirect_buffer_handle_t;
        access: access_t) {.cdecl.}
    encoder_set_image*: proc (this: ptr encoder_t; stage: uint8_t;
                            handle: texture_handle_t; mip: uint8_t;
                            access: access_t; format: texture_format_t) {.
        cdecl.}
    encoder_dispatch*: proc (this: ptr encoder_t; id: view_id_t;
                           program: program_handle_t; numX: uint32;
                           numY: uint32; numZ: uint32) {.cdecl.}
    encoder_dispatch_indirect*: proc (this: ptr encoder_t; id: view_id_t;
                                    program: program_handle_t;
        indirectHandle: indirect_buffer_handle_t; start: uint16;
                                    num: uint16) {.cdecl.}
    encoder_discard*: proc (this: ptr encoder_t) {.cdecl.}
    encoder_blit*: proc (this: ptr encoder_t; id: view_id_t;
                       dst: texture_handle_t; dstMip: uint8_t;
                       dstX: uint16; dstY: uint16; dstZ: uint16;
                       src: texture_handle_t; srcMip: uint8_t;
                       srcX: uint16; srcY: uint16; srcZ: uint16;
                       width: uint16; height: uint16; depth: uint16) {.cdecl.}
    request_screen_shot*: proc (handle: frame_buffer_handle_t;
                              filePath: cstring) {.cdecl.}
    render_frame*: proc (msecs: int32_t): render_frame_t {.cdecl.}
    set_platform_data*: proc (data: ptr platform_data_t) {.cdecl.}
    get_internal_data*: proc (): ptr internal_data_t {.cdecl.}
    override_internal_texture_ptr*: proc (handle: texture_handle_t;
                                        ptr: uintptr_t): uintptr_t {.cdecl.}
    override_internal_texture*: proc (handle: texture_handle_t;
                                    width: uint16; height: uint16;
                                    numMips: uint8_t;
                                    format: texture_format_t;
                                    flags: uint64): uintptr_t {.cdecl.}
    set_marker*: proc (marker: cstring) {.cdecl.}
    set_state*: proc (state: uint64; rgba: uint32) {.cdecl.}
    set_condition*: proc (handle: occlusion_query_handle_t; visible: bool) {.
        cdecl.}
    set_stencil*: proc (fstencil: uint32; bstencil: uint32) {.cdecl.}
    set_scissor*: proc (x: uint16; y: uint16; width: uint16; height: uint16): uint16 {.
        cdecl.}
    set_scissor_cached*: proc (cache: uint16) {.cdecl.}
    set_transform*: proc (mtx: pointer; num: uint16): uint32 {.cdecl.}
    set_transform_cached*: proc (cache: uint32; num: uint16) {.cdecl.}
    alloc_transform*: proc (transform: ptr transform_t; num: uint16): uint32 {.
        cdecl.}
    set_uniform*: proc (handle: uniform_handle_t; value: pointer;
                      num: uint16) {.cdecl.}
    set_index_buffer*: proc (handle: index_buffer_handle_t;
                           firstIndex: uint32; numIndices: uint32) {.cdecl.}
    set_dynamic_index_buffer*: proc (handle: dynamic_index_buffer_handle_t;
                                   firstIndex: uint32; numIndices: uint32) {.
        cdecl.}
    set_transient_index_buffer*: proc (tib: ptr transient_index_buffer_t;
                                     firstIndex: uint32; numIndices: uint32) {.
        cdecl.}
    set_vertex_buffer*: proc (stream: uint8_t;
                            handle: vertex_buffer_handle_t;
                            startVertex: uint32; numVertices: uint32) {.cdecl.}
    set_dynamic_vertex_buffer*: proc (stream: uint8_t; handle: dynamic_vertex_buffer_handle_t;
                                    startVertex: uint32; numVertices: uint32) {.
        cdecl.}
    set_transient_vertex_buffer*: proc (stream: uint8_t;
                                      tvb: ptr transient_vertex_buffer_t;
                                      startVertex: uint32;
                                      numVertices: uint32) {.cdecl.}
    set_vertex_count*: proc (numVertices: uint32) {.cdecl.}
    set_instance_data_buffer*: proc (idb: ptr instance_data_buffer_t;
                                   start: uint32; num: uint32) {.cdecl.}
    set_instance_data_from_vertex_buffer*: proc (
        handle: vertex_buffer_handle_t; startVertex: uint32; num: uint32) {.
        cdecl.}
    set_instance_data_from_dynamic_vertex_buffer*: proc (
        handle: dynamic_vertex_buffer_handle_t; startVertex: uint32;
        num: uint32) {.cdecl.}
    set_instance_count*: proc (numInstances: uint32) {.cdecl.}
    set_texture*: proc (stage: uint8_t; sampler: uniform_handle_t;
                      handle: texture_handle_t; flags: uint32) {.cdecl.}
    touch*: proc (id: view_id_t) {.cdecl.}
    submit*: proc (id: view_id_t; program: program_handle_t;
                 depth: uint32; preserveState: bool) {.cdecl.}
    submit_occlusion_query*: proc (id: view_id_t;
                                 program: program_handle_t; occlusionQuery: occlusion_query_handle_t;
                                 depth: uint32; preserveState: bool) {.cdecl.}
    submit_indirect*: proc (id: view_id_t; program: program_handle_t;
                          indirectHandle: indirect_buffer_handle_t;
                          start: uint16; num: uint16; depth: uint32;
                          preserveState: bool) {.cdecl.}
    set_compute_index_buffer*: proc (stage: uint8_t;
                                   handle: index_buffer_handle_t;
                                   access: access_t) {.cdecl.}
    set_compute_vertex_buffer*: proc (stage: uint8_t;
                                    handle: vertex_buffer_handle_t;
                                    access: access_t) {.cdecl.}
    set_compute_dynamic_index_buffer*: proc (stage: uint8_t;
        handle: dynamic_index_buffer_handle_t; access: access_t) {.cdecl.}
    set_compute_dynamic_vertex_buffer*: proc (stage: uint8_t;
        handle: dynamic_vertex_buffer_handle_t; access: access_t) {.
        cdecl.}
    set_compute_indirect_buffer*: proc (stage: uint8_t;
                                      handle: indirect_buffer_handle_t;
                                      access: access_t) {.cdecl.}
    set_image*: proc (stage: uint8_t; handle: texture_handle_t; mip: uint8_t;
                    access: access_t; format: texture_format_t) {.cdecl.}
    dispatch*: proc (id: view_id_t; program: program_handle_t;
                   numX: uint32; numY: uint32; numZ: uint32) {.cdecl.}
    dispatch_indirect*: proc (id: view_id_t; program: program_handle_t;
                            indirectHandle: indirect_buffer_handle_t;
                            start: uint16; num: uint16) {.cdecl.}
    `discard`*: proc () {.cdecl.}
    blit*: proc (id: view_id_t; dst: texture_handle_t; dstMip: uint8_t;
               dstX: uint16; dstY: uint16; dstZ: uint16;
               src: texture_handle_t; srcMip: uint8_t; srcX: uint16;
               srcY: uint16; srcZ: uint16; width: uint16; height: uint16;
               depth: uint16) {.cdecl.}


type
  PFN_GET_INTERFACE* = proc (version: uint32): ptr interface_vtbl {.
      cdecl.}


proc get_interface*(version: uint32): ptr interface_vtbl {.cdecl,
    importc: "bgfx_get_interface", dynlib: lib.}
