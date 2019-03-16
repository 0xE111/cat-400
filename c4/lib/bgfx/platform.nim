{.deadCodeElim: on.}
when defined(windows):
  const bgfxdll* = "libbgfx.dll"
elif defined(macosx):
  const bgfxdll* = "libbgfx.dylib"
else:
  const bgfxdll* = "libbgfx.so"

import defines, bgfx

type
  render_frame_t* {.size: sizeof(cint).} = enum
    RENDER_FRAME_NO_CONTEXT, RENDER_FRAME_RENDER,
    RENDER_FRAME_TIMEOUT, RENDER_FRAME_EXITING, RENDER_FRAME_COUNT


proc render_frame*(msecs: int32): render_frame_t {.importc: "bgfx_render_frame", dynlib: bgfxdll.}
proc set_platform_data*(data: ptr platform_data_t) {.importc: "bgfx_set_platform_data", dynlib: bgfxdll.}
type
  internal_data_t* {.bycopy.} = object
    caps*: ptr caps_t
    context*: pointer

proc get_internal_data*(): ptr internal_data_t {.importc: "bgfx_get_internal_data", dynlib: bgfxdll.}
proc override_internal_texture_ptr*(handle: texture_handle_t; `ptr`: pointer): pointer {.importc: "bgfx_override_internal_texture_ptr", dynlib: bgfxdll.}
proc override_internal_texture*(handle: texture_handle_t; width: uint16; height: uint16; numMips: uint8; format: texture_format_t; flags: uint32): pointer {.importc: "bgfx_override_internal_texture", dynlib: bgfxdll.}

type
  interface_vtbl_t* {.bycopy.} = object
    render_frame*: proc (msecs: int32): render_frame_t
    set_platform_data*: proc (data: ptr platform_data_t)
    get_internal_data*: proc (): ptr internal_data_t
    override_internal_texture_ptr*: proc (handle: texture_handle_t;
                                        `ptr`: pointer): pointer
    override_internal_texture*: proc (handle: texture_handle_t; width: uint16;
                                    height: uint16; numMips: uint8;
                                    format: texture_format_t; flags: uint32): pointer
    vertex_decl_begin*: proc (decl: ptr vertex_decl_t;
                            renderer: renderer_type_t)
    vertex_decl_add*: proc (decl: ptr vertex_decl_t; attrib: attrib_t;
                          num: uint8; `type`: attrib_type_t; normalized: bool;
                          asInt: bool)
    vertex_decl_decode*: proc (decl: ptr vertex_decl_t; attrib: attrib_t;
                             num: ptr uint8; `type`: ptr attrib_type_t;
                             normalized: ptr bool; asInt: ptr bool)
    vertex_decl_has*: proc (decl: ptr vertex_decl_t; attrib: attrib_t): bool
    vertex_decl_skip*: proc (decl: ptr vertex_decl_t; num: uint8)
    vertex_decl_end*: proc (decl: ptr vertex_decl_t)
    vertex_pack*: proc (input: array[4, cfloat]; inputNormalized: bool;
                      attr: attrib_t; decl: ptr vertex_decl_t;
                      data: pointer; index: uint32)
    vertex_unpack*: proc (output: array[4, cfloat]; attr: attrib_t;
                        decl: ptr vertex_decl_t; data: pointer; index: uint32)
    vertex_convert*: proc (destDecl: ptr vertex_decl_t; destData: pointer;
                         srcDecl: ptr vertex_decl_t; srcData: pointer;
                         num: uint32)
    weld_vertices*: proc (output: ptr uint16; decl: ptr vertex_decl_t;
                        data: pointer; num: uint16; epsilon: cfloat): uint16
    topology_convert*: proc (conversion: topology_convert_t; dst: pointer;
                           dstSize: uint32; indices: pointer; numIndices: uint32;
                           index32: bool): uint32
    topology_sort_tri_list*: proc (sort: topology_sort_t; dst: pointer;
                                 dstSize: uint32; dir: array[3, cfloat];
                                 pos: array[3, cfloat]; vertices: pointer;
                                 stride: uint32; indices: pointer;
                                 numIndices: uint32; index32: bool)
    get_supported_renderers*: proc (max: uint8; `enum`: ptr renderer_type_t): uint8
    get_renderer_name*: proc (`type`: renderer_type_t): cstring
    init_ctor*: proc (init: ptr init_t)
    init*: proc (init: ptr init_t): bool
    shutdown*: proc ()
    reset*: proc (width: uint32; height: uint32; flags: uint32;
                format: texture_format_t)
    frame*: proc (capture: bool): uint32
    get_renderer_type*: proc (): renderer_type_t
    get_caps*: proc (): ptr caps_t
    get_stats*: proc (): ptr stats_t
    alloc*: proc (size: uint32): ptr memory_t
    copy*: proc (data: pointer; size: uint32): ptr memory_t
    make_ref*: proc (data: pointer; size: uint32): ptr memory_t
    make_ref_release*: proc (data: pointer; size: uint32;
                           releaseFn: release_fn_t; userData: pointer): ptr memory_t
    set_debug*: proc (debug: uint32)
    dbg_text_clear*: proc (attr: uint8; small: bool)
    dbg_text_printf*: proc (x: uint16; y: uint16; attr: uint8; format: cstring) {.varargs.}
    dbg_text_vprintf*: proc (x: uint16; y: uint16; attr: uint8; format: cstring;
                           argList: va_list)
    dbg_text_image*: proc (x: uint16; y: uint16; width: uint16; height: uint16;
                         data: pointer; pitch: uint16)
    create_index_buffer*: proc (mem: ptr memory_t; flags: uint16): index_buffer_handle_t
    destroy_index_buffer*: proc (handle: index_buffer_handle_t)
    create_vertex_buffer*: proc (mem: ptr memory_t;
                               decl: ptr vertex_decl_t; flags: uint16): vertex_buffer_handle_t
    destroy_vertex_buffer*: proc (handle: vertex_buffer_handle_t)
    create_dynamic_index_buffer*: proc (num: uint32; flags: uint16): dynamic_index_buffer_handle_t
    create_dynamic_index_buffer_mem*: proc (mem: ptr memory_t; flags: uint16): dynamic_index_buffer_handle_t
    update_dynamic_index_buffer*: proc (handle: dynamic_index_buffer_handle_t;
                                      startIndex: uint32; mem: ptr memory_t)
    destroy_dynamic_index_buffer*: proc (handle: dynamic_index_buffer_handle_t)
    create_dynamic_vertex_buffer*: proc (num: uint32; decl: ptr vertex_decl_t;
                                       flags: uint16): dynamic_vertex_buffer_handle_t
    create_dynamic_vertex_buffer_mem*: proc (mem: ptr memory_t;
        decl: ptr vertex_decl_t; flags: uint16): dynamic_vertex_buffer_handle_t
    update_dynamic_vertex_buffer*: proc (handle: dynamic_vertex_buffer_handle_t;
                                       startVertex: uint32; mem: ptr memory_t)
    destroy_dynamic_vertex_buffer*: proc (handle: dynamic_vertex_buffer_handle_t)
    get_avail_transient_index_buffer*: proc (num: uint32): uint32
    get_avail_transient_vertex_buffer*: proc (num: uint32;
        decl: ptr vertex_decl_t): uint32
    get_avail_instance_data_buffer*: proc (num: uint32; stride: uint16): uint32
    alloc_transient_index_buffer*: proc (tib: ptr transient_index_buffer_t;
                                       num: uint32)
    alloc_transient_vertex_buffer*: proc (tvb: ptr transient_vertex_buffer_t;
                                        num: uint32; decl: ptr vertex_decl_t)
    alloc_transient_buffers*: proc (tvb: ptr transient_vertex_buffer_t;
                                  decl: ptr vertex_decl_t;
                                  numVertices: uint32;
                                  tib: ptr transient_index_buffer_t;
                                  numIndices: uint32): bool
    alloc_instance_data_buffer*: proc (idb: ptr instance_data_buffer_t;
                                     num: uint32; stride: uint16)
    create_indirect_buffer*: proc (num: uint32): indirect_buffer_handle_t
    destroy_indirect_buffer*: proc (handle: indirect_buffer_handle_t)
    create_shader*: proc (mem: ptr memory_t): shader_handle_t
    get_shader_uniforms*: proc (handle: shader_handle_t;
                              uniforms: ptr uniform_handle_t; max: uint16): uint16
    set_shader_name*: proc (handle: shader_handle_t; name: cstring; len: int32)
    destroy_shader*: proc (handle: shader_handle_t)
    create_program*: proc (vsh: shader_handle_t; fsh: shader_handle_t;
                         destroyShaders: bool): program_handle_t
    create_compute_program*: proc (csh: shader_handle_t; destroyShaders: bool): program_handle_t
    destroy_program*: proc (handle: program_handle_t)
    is_texture_valid*: proc (depth: uint16; cubeMap: bool; numLayers: uint16;
                           format: texture_format_t; flags: uint64): bool
    calc_texture_size*: proc (info: ptr texture_info_t; width: uint16;
                            height: uint16; depth: uint16; cubeMap: bool;
                            hasMips: bool; numLayers: uint16;
                            format: texture_format_t)
    create_texture*: proc (mem: ptr memory_t; flags: uint64; skip: uint8;
                         info: ptr texture_info_t): texture_handle_t
    create_texture_2d*: proc (width: uint16; height: uint16; hasMips: bool;
                            numLayers: uint16; format: texture_format_t;
                            flags: uint64; mem: ptr memory_t): texture_handle_t
    create_texture_2d_scaled*: proc (ratio: backbuffer_ratio_t; hasMips: bool;
                                   numLayers: uint16;
                                   format: texture_format_t; flags: uint64): texture_handle_t
    create_texture_3d*: proc (width: uint16; height: uint16; depth: uint16;
                            hasMips: bool; format: texture_format_t;
                            flags: uint64; mem: ptr memory_t): texture_handle_t
    create_texture_cube*: proc (size: uint16; hasMips: bool; numLayers: uint16;
                              format: texture_format_t; flags: uint64;
                              mem: ptr memory_t): texture_handle_t
    update_texture_2d*: proc (handle: texture_handle_t; layer: uint16;
                            mip: uint8; x: uint16; y: uint16; width: uint16;
                            height: uint16; mem: ptr memory_t; pitch: uint16)
    update_texture_3d*: proc (handle: texture_handle_t; mip: uint8; x: uint16;
                            y: uint16; z: uint16; width: uint16; height: uint16;
                            depth: uint16; mem: ptr memory_t)
    update_texture_cube*: proc (handle: texture_handle_t; layer: uint16;
                              side: uint8; mip: uint8; x: uint16; y: uint16;
                              width: uint16; height: uint16; mem: ptr memory_t;
                              pitch: uint16)
    read_texture*: proc (handle: texture_handle_t; data: pointer; mip: uint8): uint32
    set_texture_name*: proc (handle: texture_handle_t; name: cstring; len: int32)
    get_direct_access_ptr*: proc (handle: texture_handle_t): pointer
    destroy_texture*: proc (handle: texture_handle_t)
    create_frame_buffer*: proc (width: uint16; height: uint16;
                              format: texture_format_t; textureFlags: uint64): frame_buffer_handle_t
    create_frame_buffer_scaled*: proc (ratio: backbuffer_ratio_t;
                                     format: texture_format_t;
                                     textureFlags: uint64): frame_buffer_handle_t
    create_frame_buffer_from_attachment*: proc (num: uint8;
        attachment: ptr attachment_t; destroyTextures: bool): frame_buffer_handle_t
    create_frame_buffer_from_nwh*: proc (nwh: pointer; width: uint16; height: uint16;
                                       format: texture_format_t;
                                       depthFormat: texture_format_t): frame_buffer_handle_t
    get_texture*: proc (handle: frame_buffer_handle_t; attachment: uint8): texture_handle_t
    destroy_frame_buffer*: proc (handle: frame_buffer_handle_t)
    create_uniform*: proc (name: cstring; `type`: uniform_type_t; num: uint16): uniform_handle_t
    get_uniform_info*: proc (handle: uniform_handle_t;
                           info: ptr uniform_info_t)
    destroy_uniform*: proc (handle: uniform_handle_t)
    create_occlusion_query*: proc (): occlusion_query_handle_t
    get_result*: proc (handle: occlusion_query_handle_t; result: ptr int32): occlusion_query_result_t
    destroy_occlusion_query*: proc (handle: occlusion_query_handle_t)
    set_palette_color*: proc (index: uint8; rgba: array[4, cfloat])
    set_view_name*: proc (id: view_id_t; name: cstring)
    set_view_rect*: proc (id: view_id_t; x: uint16; y: uint16; width: uint16;
                        height: uint16)
    set_view_scissor*: proc (id: view_id_t; x: uint16; y: uint16; width: uint16;
                           height: uint16)
    set_view_clear*: proc (id: view_id_t; flags: uint16; rgba: uint32;
                         depth: cfloat; stencil: uint8)
    set_view_clear_mrt*: proc (id: view_id_t; flags: uint16; depth: cfloat;
                             stencil: uint8; v0: uint8; v1: uint8; v2: uint8; v3: uint8;
                             v4: uint8; v5: uint8; v6: uint8; v7: uint8)
    set_view_mode*: proc (id: view_id_t; mode: view_mode_t)
    set_view_frame_buffer*: proc (id: view_id_t;
                                handle: frame_buffer_handle_t)
    set_view_transform*: proc (id: view_id_t; view: pointer; proj: pointer)
    set_view_transform_stereo*: proc (id: view_id_t; view: pointer;
                                    projL: pointer; flags: uint8; projR: pointer)
    set_view_order*: proc (id: view_id_t; num: uint16; order: ptr view_id_t)
    encoder_set_marker*: proc (encoder: ptr encoder_s; marker: cstring)
    encoder_set_state*: proc (encoder: ptr encoder_s; state: uint64; rgba: uint32)
    encoder_set_condition*: proc (encoder: ptr encoder_s;
                                handle: occlusion_query_handle_t;
                                visible: bool)
    encoder_set_stencil*: proc (encoder: ptr encoder_s; fstencil: uint32;
                              bstencil: uint32)
    encoder_set_scissor*: proc (encoder: ptr encoder_s; x: uint16; y: uint16;
                              width: uint16; height: uint16): uint16
    encoder_set_scissor_cached*: proc (encoder: ptr encoder_s; cache: uint16)
    encoder_set_transform*: proc (encoder: ptr encoder_s; mtx: pointer;
                                num: uint16): uint32
    encoder_alloc_transform*: proc (encoder: ptr encoder_s;
                                  transform: ptr transform_t; num: uint16): uint32
    encoder_set_transform_cached*: proc (encoder: ptr encoder_s; cache: uint32;
                                       num: uint16)
    encoder_set_uniform*: proc (encoder: ptr encoder_s;
                              handle: uniform_handle_t; value: pointer;
                              num: uint16)
    encoder_set_index_buffer*: proc (encoder: ptr encoder_s;
                                   handle: index_buffer_handle_t;
                                   firstIndex: uint32; numIndices: uint32)
    encoder_set_dynamic_index_buffer*: proc (encoder: ptr encoder_s;
        handle: dynamic_index_buffer_handle_t; firstIndex: uint32;
        numIndices: uint32)
    encoder_set_transient_index_buffer*: proc (encoder: ptr encoder_s;
        tib: ptr transient_index_buffer_t; firstIndex: uint32;
        numIndices: uint32)
    encoder_set_vertex_buffer*: proc (encoder: ptr encoder_s; stream: uint8;
                                    handle: vertex_buffer_handle_t;
                                    startVertex: uint32; numVertices: uint32)
    encoder_set_dynamic_vertex_buffer*: proc (encoder: ptr encoder_s;
        stream: uint8; handle: dynamic_vertex_buffer_handle_t;
        startVertex: uint32; numVertices: uint32)
    encoder_set_transient_vertex_buffer*: proc (encoder: ptr encoder_s;
        stream: uint8; tvb: ptr transient_vertex_buffer_t; startVertex: uint32;
        numVertices: uint32)
    encoder_set_vertex_count*: proc (encoder: ptr encoder_s; numVertices: uint32)
    encoder_set_instance_data_buffer*: proc (encoder: ptr encoder_s;
        idb: ptr instance_data_buffer_t; start: uint32; num: uint32)
    encoder_set_instance_data_from_vertex_buffer*: proc (
        encoder: ptr encoder_s; handle: vertex_buffer_handle_t;
        startVertex: uint32; num: uint32)
    encoder_set_instance_data_from_dynamic_vertex_buffer*: proc (
        encoder: ptr encoder_s; handle: dynamic_vertex_buffer_handle_t;
        startVertex: uint32; num: uint32)
    encoder_set_instance_count*: proc (encoder: ptr encoder_s;
                                     numInstance: uint32)
    encoder_set_texture*: proc (encoder: ptr encoder_s; stage: uint8;
                              sampler: uniform_handle_t;
                              handle: texture_handle_t; flags: uint32)
    encoder_touch*: proc (encoder: ptr encoder_s; id: view_id_t)
    encoder_submit*: proc (encoder: ptr encoder_s; id: view_id_t;
                         handle: program_handle_t; depth: uint32;
                         preserveState: bool)
    encoder_submit_occlusion_query*: proc (encoder: ptr encoder_s;
        id: view_id_t; program: program_handle_t;
        occlusionQuery: occlusion_query_handle_t; depth: uint32;
        preserveState: bool)
    encoder_submit_indirect*: proc (encoder: ptr encoder_s; id: view_id_t;
                                  handle: program_handle_t; indirectHandle: indirect_buffer_handle_t;
                                  start: uint16; num: uint16; depth: uint32;
                                  preserveState: bool)
    encoder_set_image*: proc (encoder: ptr encoder_s; stage: uint8;
                            handle: texture_handle_t; mip: uint8;
                            access: access_t; format: texture_format_t)
    encoder_set_compute_index_buffer*: proc (encoder: ptr encoder_s;
        stage: uint8; handle: index_buffer_handle_t; access: access_t)
    encoder_set_compute_vertex_buffer*: proc (encoder: ptr encoder_s;
        stage: uint8; handle: vertex_buffer_handle_t; access: access_t)
    encoder_set_compute_dynamic_index_buffer*: proc (encoder: ptr encoder_s;
        stage: uint8; handle: dynamic_index_buffer_handle_t;
        access: access_t)
    encoder_set_compute_dynamic_vertex_buffer*: proc (encoder: ptr encoder_s;
        stage: uint8; handle: dynamic_vertex_buffer_handle_t;
        access: access_t)
    encoder_set_compute_indirect_buffer*: proc (encoder: ptr encoder_s;
        stage: uint8; handle: indirect_buffer_handle_t; access: access_t)
    encoder_dispatch*: proc (encoder: ptr encoder_s; id: view_id_t;
                           handle: program_handle_t; numX: uint32;
                           numY: uint32; numZ: uint32; flags: uint8)
    encoder_dispatch_indirect*: proc (encoder: ptr encoder_s;
                                    id: view_id_t;
                                    handle: program_handle_t; indirectHandle: indirect_buffer_handle_t;
                                    start: uint16; num: uint16; flags: uint8)
    encoder_discard*: proc (encoder: ptr encoder_s)
    encoder_blit*: proc (encoder: ptr encoder_s; id: view_id_t;
                       dst: texture_handle_t; dstMip: uint8; dstX: uint16;
                       dstY: uint16; dstZ: uint16; src: texture_handle_t;
                       srcMip: uint8; srcX: uint16; srcY: uint16; srcZ: uint16;
                       width: uint16; height: uint16; depth: uint16)
    request_screen_shot*: proc (handle: frame_buffer_handle_t;
                              filePath: cstring)

  PFN_GET_INTERFACE* = proc (version: uint32): ptr interface_vtbl_t
