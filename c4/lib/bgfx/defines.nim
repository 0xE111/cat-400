{.deadCodeElim: on.}

const
  API_VERSION* = (90)

## / Color RGB/alpha/depth write. When it's not specified write will be disabled.

const
  STATE_WRITE_R* = (0x0000000000000001'u64) ## !< Enable R write.
  STATE_WRITE_G* = (0x0000000000000002'u64) ## !< Enable G write.
  STATE_WRITE_B* = (0x0000000000000004'u64) ## !< Enable B write.
  STATE_WRITE_A* = (0x0000000000000008'u64) ## !< Enable alpha write.
  STATE_WRITE_Z* = (0x0000004000000000'u64) ## !< Enable depth write.

## / Enable RGB write.

const
  STATE_WRITE_RGB* = (
    0'u64 or STATE_WRITE_R or STATE_WRITE_G or STATE_WRITE_B)

## / Write all channels mask.

const
  STATE_WRITE_MASK* = (
    0'u64 or STATE_WRITE_RGB or STATE_WRITE_A or STATE_WRITE_Z)

## / Depth test state. When `STATE_DEPTH_` is not specified depth test will be disabled.

const
  STATE_DEPTH_TEST_LESS* = (0x0000000000000010'u64) ## !< Enable depth test, less.
  STATE_DEPTH_TEST_LEQUAL* = (0x0000000000000020'u64) ## !< Enable depth test, less or equal.
  STATE_DEPTH_TEST_EQUAL* = (0x0000000000000030'u64) ## !< Enable depth test, equal.
  STATE_DEPTH_TEST_GEQUAL* = (0x0000000000000040'u64) ## !< Enable depth test, greater or equal.
  STATE_DEPTH_TEST_GREATER* = (0x0000000000000050'u64) ## !< Enable depth test, greater.
  STATE_DEPTH_TEST_NOTEQUAL* = (0x0000000000000060'u64) ## !< Enable depth test, not equal.
  STATE_DEPTH_TEST_NEVER* = (0x0000000000000070'u64) ## !< Enable depth test, never.
  STATE_DEPTH_TEST_ALWAYS* = (0x0000000000000080'u64) ## !< Enable depth test, always.
  STATE_DEPTH_TEST_SHIFT* = 4
  STATE_DEPTH_TEST_MASK* = (0x00000000000000F0'u64) ## !< Depth test state bit mask.

## / Use STATE_BLEND_FUNC(_src, _dst) or STATE_BLEND_FUNC_SEPARATE(_srcRGB, _dstRGB, _srcA, _dstA)
## / helper macros.

const
  STATE_BLEND_ZERO* = (0x0000000000001000'u64) ## !< 0, 0, 0, 0
  STATE_BLEND_ONE* = (0x0000000000002000'u64) ## !< 1, 1, 1, 1
  STATE_BLEND_SRC_COLOR* = (0x0000000000003000'u64) ## !< Rs, Gs, Bs, As
  STATE_BLEND_INV_SRC_COLOR* = (0x0000000000004000'u64) ## !< 1-Rs, 1-Gs, 1-Bs, 1-As
  STATE_BLEND_SRC_ALPHA* = (0x0000000000005000'u64) ## !< As, As, As, As
  STATE_BLEND_INV_SRC_ALPHA* = (0x0000000000006000'u64) ## !< 1-As, 1-As, 1-As, 1-As
  STATE_BLEND_DST_ALPHA* = (0x0000000000007000'u64) ## !< Ad, Ad, Ad, Ad
  STATE_BLEND_INV_DST_ALPHA* = (0x0000000000008000'u64) ## !< 1-Ad, 1-Ad, 1-Ad ,1-Ad
  STATE_BLEND_DST_COLOR* = (0x0000000000009000'u64) ## !< Rd, Gd, Bd, Ad
  STATE_BLEND_INV_DST_COLOR* = (0x000000000000A000'u64) ## !< 1-Rd, 1-Gd, 1-Bd, 1-Ad
  STATE_BLEND_SRC_ALPHA_SAT* = (0x000000000000B000'u64) ## !< f, f, f, 1; f = min(As, 1-Ad)
  STATE_BLEND_FACTOR* = (0x000000000000C000'u64) ## !< Blend factor
  STATE_BLEND_INV_FACTOR* = (0x000000000000D000'u64) ## !< 1-Blend factor
  STATE_BLEND_SHIFT* = 12
  STATE_BLEND_MASK* = (0x000000000FFFF000'u64) ## !< Blend state bit mask.

## / Use STATE_BLEND_EQUATION(_equation) or STATE_BLEND_EQUATION_SEPARATE(_equationRGB, _equationA)
## / helper macros.

const
  STATE_BLEND_EQUATION_ADD* = (0x0000000000000000'u64) ## !< Blend add: src + dst.
  STATE_BLEND_EQUATION_SUB* = (0x0000000010000000'u64) ## !< Blend subtract: src - dst.
  STATE_BLEND_EQUATION_REVSUB* = (0x0000000020000000'u64) ## !< Blend reverse subtract: dst - src.
  STATE_BLEND_EQUATION_MIN* = (0x0000000030000000'u64) ## !< Blend min: min(src, dst).
  STATE_BLEND_EQUATION_MAX* = (0x0000000040000000'u64) ## !< Blend max: max(src, dst).
  STATE_BLEND_EQUATION_SHIFT* = 28
  STATE_BLEND_EQUATION_MASK* = (0x00000003F0000000'u64) ## !< Blend equation bit mask.
  STATE_BLEND_INDEPENDENT* = (0x0000000400000000'u64) ## !< Enable blend independent.
  STATE_BLEND_ALPHA_TO_COVERAGE* = (0x0000000800000000'u64) ## !< Enable alpha to coverage.

## / Cull state. When `STATE_CULL_*` is not specified culling will be disabled.

const
  STATE_CULL_CW* = (0x0000001000000000'u64) ## !< Cull clockwise triangles.
  STATE_CULL_CCW* = (0x0000002000000000'u64) ## !< Cull counter-clockwise triangles.
  STATE_CULL_SHIFT* = 36
  STATE_CULL_MASK* = (0x0000003000000000'u64) ## !< Culling mode bit mask.

## / See STATE_ALPHA_REF(_ref) helper macro.

const
  STATE_ALPHA_REF_SHIFT* = 40
  STATE_ALPHA_REF_MASK* = (0x0000FF0000000000'u64) ## !< Alpha reference bit mask.
  STATE_PT_TRISTRIP* = (0x0001000000000000'u64) ## !< Tristrip.
  STATE_PT_LINES* = (0x0002000000000000'u64) ## !< Lines.
  STATE_PT_LINESTRIP* = (0x0003000000000000'u64) ## !< Line strip.
  STATE_PT_POINTS* = (0x0004000000000000'u64) ## !< Points.
  STATE_PT_SHIFT* = 48
  STATE_PT_MASK* = (0x0007000000000000'u64) ## !< Primitive type bit mask.

## / See STATE_POINT_SIZE(_size) helper macro.

const
  STATE_POINT_SIZE_SHIFT* = 52
  STATE_POINT_SIZE_MASK* = (0x00F0000000000000'u64) ## !< Point size bit mask.

## / Enable MSAA write when writing into MSAA frame buffer.
## / This flag is ignored when not writing into MSAA frame buffer.

const
  STATE_MSAA* = (0x0100000000000000'u64) ## !< Enable MSAA rasterization.
  STATE_LINEAA* = (0x0200000000000000'u64) ## !< Enable line AA rasterization.
  STATE_CONSERVATIVE_RASTER* = (0x0400000000000000'u64) ## !< Enable conservative rasterization.

## / Do not use!

const
  STATE_RESERVED_SHIFT* = 61
  STATE_RESERVED_MASK* = (0xE000000000000000'u64) ## !< Internal bits mask.

## /

const
  STATE_NONE* = (0x0000000000000000'u64) ## !< No state.
  STATE_MASK* = (0xFFFFFFFFFFFFFFFF'u64) ## !< State mask.

## / Default state is write to RGB, alpha, and depth with depth test less enabled, with clockwise
## / culling and MSAA (when writing into MSAA frame buffer, otherwise this flag is ignored).

const
  STATE_DEFAULT* = (0'u64 or STATE_WRITE_RGB or STATE_WRITE_A or
      STATE_WRITE_Z or STATE_DEPTH_TEST_LESS or STATE_CULL_CW or
      STATE_MSAA)

## / Alpha reference value.

template STATE_ALPHA_REF*(`ref`: untyped): untyped =
  (((uint64)(`ref`) shl STATE_ALPHA_REF_SHIFT) and
      STATE_ALPHA_REF_MASK)

## / Point size value.

template STATE_POINT_SIZE*(size: untyped): untyped =
  (((uint64)(size) shl STATE_POINT_SIZE_SHIFT) and
      STATE_POINT_SIZE_MASK)

## / Blend function separate.

template STATE_BLEND_FUNC_SEPARATE*(srcRGB, dstRGB, srcA, dstA: untyped): untyped =
  ((0'u64) or (((uint64)(srcRGB) or ((uint64)(dstRGB) shl 4))) or
      (((uint64)(srcA) or ((uint64)(dstA) shl 4)) shl 8))

## / Blend equation separate.

template STATE_BLEND_EQUATION_SEPARATE*(equationRGB, equationA: untyped): untyped =
  ((uint64)(equationRGB) or ((uint64)(equationA) shl 3))

## / Blend function.

template STATE_BLEND_FUNC*(src, dst: untyped): untyped =
  STATE_BLEND_FUNC_SEPARATE(src, dst, src, dst)

## / Blend equation.

template STATE_BLEND_EQUATION*(equation: untyped): untyped =
  STATE_BLEND_EQUATION_SEPARATE(equation, equation)

## / Utility predefined blend modes.
## / Additive blending.

const
  STATE_BLEND_ADD* = (
    0'u64 or STATE_BLEND_FUNC(STATE_BLEND_ONE, STATE_BLEND_ONE))

## / Alpha blend.

const
  STATE_BLEND_ALPHA* = (0'u64 or
      STATE_BLEND_FUNC(STATE_BLEND_SRC_ALPHA,
                            STATE_BLEND_INV_SRC_ALPHA))

## / Selects darker color of blend.

const
  STATE_BLEND_DARKEN* = (0'u64 or
      STATE_BLEND_FUNC(STATE_BLEND_ONE, STATE_BLEND_ONE) or
      STATE_BLEND_EQUATION(STATE_BLEND_EQUATION_MIN))

## / Selects lighter color of blend.

const
  STATE_BLEND_LIGHTEN* = (0'u64 or
      STATE_BLEND_FUNC(STATE_BLEND_ONE, STATE_BLEND_ONE) or
      STATE_BLEND_EQUATION(STATE_BLEND_EQUATION_MAX))

## / Multiplies colors.

const
  STATE_BLEND_MULTIPLY* = (0'u64 or
      STATE_BLEND_FUNC(STATE_BLEND_DST_COLOR, STATE_BLEND_ZERO))

## / Opaque pixels will cover the pixels directly below them without any math or algorithm applied to them.

const
  STATE_BLEND_NORMAL* = (0'u64 or
      STATE_BLEND_FUNC(STATE_BLEND_ONE, STATE_BLEND_INV_SRC_ALPHA))

## / Multiplies the inverse of the blend and base colors.

const
  STATE_BLEND_SCREEN* = (0'u64 or
      STATE_BLEND_FUNC(STATE_BLEND_ONE, STATE_BLEND_INV_SRC_COLOR))

## / Decreases the brightness of the base color based on the value of the blend color.

const
  STATE_BLEND_LINEAR_BURN* = (0'u64 or
      STATE_BLEND_FUNC(STATE_BLEND_DST_COLOR,
                            STATE_BLEND_INV_DST_COLOR) or
      STATE_BLEND_EQUATION(STATE_BLEND_EQUATION_SUB))

## /

template STATE_BLEND_FUNC_RT_x*(src, dst: untyped): untyped =
  (0'u64 or
      ((uint32)((src) shr STATE_BLEND_SHIFT) or
      ((uint32)((dst) shr STATE_BLEND_SHIFT) shl 4)))

## /

template STATE_BLEND_FUNC_RT_xE*(src, dst, equation: untyped): untyped =
  (0'u64 or STATE_BLEND_FUNC_RT_x(src, dst) or
      ((uint32)((equation) shr STATE_BLEND_EQUATION_SHIFT) shl 8))

template STATE_BLEND_FUNC_RT_1*(src, dst: untyped): untyped =
  (STATE_BLEND_FUNC_RT_x(src, dst) shl 0)

template STATE_BLEND_FUNC_RT_2*(src, dst: untyped): untyped =
  (STATE_BLEND_FUNC_RT_x(src, dst) shl 11)

template STATE_BLEND_FUNC_RT_3*(src, dst: untyped): untyped =
  (STATE_BLEND_FUNC_RT_x(src, dst) shl 22)

template STATE_BLEND_FUNC_RT_1E*(src, dst, equation: untyped): untyped =
  (STATE_BLEND_FUNC_RT_xE(src, dst, equation) shl 0)

template STATE_BLEND_FUNC_RT_2E*(src, dst, equation: untyped): untyped =
  (STATE_BLEND_FUNC_RT_xE(src, dst, equation) shl 11)

template STATE_BLEND_FUNC_RT_3E*(src, dst, equation: untyped): untyped =
  (STATE_BLEND_FUNC_RT_xE(src, dst, equation) shl 22)

## /

const
  STENCIL_FUNC_REF_SHIFT* = 0
  STENCIL_FUNC_REF_MASK* = (0x000000FF) ## !<
  STENCIL_FUNC_RMASK_SHIFT* = 8
  STENCIL_FUNC_RMASK_MASK* = (0x0000FF00) ## !<

## /

const
  STENCIL_TEST_LESS* = (0x00010000) ## !< Enable stencil test, less.
  STENCIL_TEST_LEQUAL* = (0x00020000) ## !< Enable stencil test, less or equal.
  STENCIL_TEST_EQUAL* = (0x00030000) ## !< Enable stencil test, equal.
  STENCIL_TEST_GEQUAL* = (0x00040000) ## !< Enable stencil test, greater or equal.
  STENCIL_TEST_GREATER* = (0x00050000) ## !< Enable stencil test, greater.
  STENCIL_TEST_NOTEQUAL* = (0x00060000) ## !< Enable stencil test, not equal.
  STENCIL_TEST_NEVER* = (0x00070000) ## !< Enable stencil test, never.
  STENCIL_TEST_ALWAYS* = (0x00080000) ## !< Enable stencil test, always.
  STENCIL_TEST_SHIFT* = 16
  STENCIL_TEST_MASK* = (0x000F0000) ## !< Stencil test bit mask.

## /

const
  STENCIL_OP_FAIL_S_ZERO* = (0x00000000) ## !< Zero.
  STENCIL_OP_FAIL_S_KEEP* = (0x00100000) ## !< Keep.
  STENCIL_OP_FAIL_S_REPLACE* = (0x00200000) ## !< Replace.
  STENCIL_OP_FAIL_S_INCR* = (0x00300000) ## !< Increment and wrap.
  STENCIL_OP_FAIL_S_INCRSAT* = (0x00400000) ## !< Increment and clamp.
  STENCIL_OP_FAIL_S_DECR* = (0x00500000) ## !< Decrement and wrap.
  STENCIL_OP_FAIL_S_DECRSAT* = (0x00600000) ## !< Decrement and clamp.
  STENCIL_OP_FAIL_S_INVERT* = (0x00700000) ## !< Invert.
  STENCIL_OP_FAIL_S_SHIFT* = 20
  STENCIL_OP_FAIL_S_MASK* = (0x00F00000) ## !< Stencil operation fail bit mask.

## /

const
  STENCIL_OP_FAIL_Z_ZERO* = (0x00000000) ## !< Zero.
  STENCIL_OP_FAIL_Z_KEEP* = (0x01000000) ## !< Keep.
  STENCIL_OP_FAIL_Z_REPLACE* = (0x02000000) ## !< Replace.
  STENCIL_OP_FAIL_Z_INCR* = (0x03000000) ## !< Increment and wrap.
  STENCIL_OP_FAIL_Z_INCRSAT* = (0x04000000) ## !< Increment and clamp.
  STENCIL_OP_FAIL_Z_DECR* = (0x05000000) ## !< Decrement and wrap.
  STENCIL_OP_FAIL_Z_DECRSAT* = (0x06000000) ## !< Decrement and clamp.
  STENCIL_OP_FAIL_Z_INVERT* = (0x07000000) ## !< Invert.
  STENCIL_OP_FAIL_Z_SHIFT* = 24
  STENCIL_OP_FAIL_Z_MASK* = (0x0F000000) ## !< Stencil operation depth fail bit mask.

## /

const
  STENCIL_OP_PASS_Z_ZERO* = (0x00000000) ## !< Zero.
  STENCIL_OP_PASS_Z_KEEP* = (0x10000000) ## !< Keep.
  STENCIL_OP_PASS_Z_REPLACE* = (0x20000000) ## !< Replace.
  STENCIL_OP_PASS_Z_INCR* = (0x30000000) ## !< Increment and wrap.
  STENCIL_OP_PASS_Z_INCRSAT* = (0x40000000) ## !< Increment and clamp.
  STENCIL_OP_PASS_Z_DECR* = (0x50000000) ## !< Decrement and wrap.
  STENCIL_OP_PASS_Z_DECRSAT* = (0x60000000) ## !< Decrement and clamp.
  STENCIL_OP_PASS_Z_INVERT* = (0x70000000) ## !< Invert.
  STENCIL_OP_PASS_Z_SHIFT* = 28
  STENCIL_OP_PASS_Z_MASK* = (0xF0000000) ## !< Stencil operation depth pass bit mask.

## /

const
  STENCIL_NONE* = (0x00000000) ## !<
  STENCIL_MASK* = (0xFFFFFFFF) ## !<
  STENCIL_DEFAULT* = (0x00000000) ## !<

## / Set stencil ref value.

template STENCIL_FUNC_REF*(`ref`: untyped): untyped =
  (((uint32)(`ref`) shl STENCIL_FUNC_REF_SHIFT) and
      STENCIL_FUNC_REF_MASK)

## / Set stencil rmask value.

template STENCIL_FUNC_RMASK*(mask: untyped): untyped =
  (((uint32)(mask) shl STENCIL_FUNC_RMASK_SHIFT) and
      STENCIL_FUNC_RMASK_MASK)

## /

const
  CLEAR_NONE* = (0x00000000) ## !< No clear flags.
  CLEAR_COLOR* = (0x00000001) ## !< Clear color.
  CLEAR_DEPTH* = (0x00000002) ## !< Clear depth.
  CLEAR_STENCIL* = (0x00000004) ## !< Clear stencil.
  CLEAR_DISCARD_COLOR_0* = (0x00000008) ## !< Discard frame buffer attachment 0.
  CLEAR_DISCARD_COLOR_1* = (0x00000010) ## !< Discard frame buffer attachment 1.
  CLEAR_DISCARD_COLOR_2* = (0x00000020) ## !< Discard frame buffer attachment 2.
  CLEAR_DISCARD_COLOR_3* = (0x00000040) ## !< Discard frame buffer attachment 3.
  CLEAR_DISCARD_COLOR_4* = (0x00000080) ## !< Discard frame buffer attachment 4.
  CLEAR_DISCARD_COLOR_5* = (0x00000100) ## !< Discard frame buffer attachment 5.
  CLEAR_DISCARD_COLOR_6* = (0x00000200) ## !< Discard frame buffer attachment 6.
  CLEAR_DISCARD_COLOR_7* = (0x00000400) ## !< Discard frame buffer attachment 7.
  CLEAR_DISCARD_DEPTH* = (0x00000800) ## !< Discard frame buffer depth attachment.
  CLEAR_DISCARD_STENCIL* = (0x00001000) ## !< Discard frame buffer stencil attachment.

## /

const
  CLEAR_DISCARD_COLOR_MASK* = (0'u64 or CLEAR_DISCARD_COLOR_0 or
      CLEAR_DISCARD_COLOR_1 or CLEAR_DISCARD_COLOR_2 or
      CLEAR_DISCARD_COLOR_3 or CLEAR_DISCARD_COLOR_4 or
      CLEAR_DISCARD_COLOR_5 or CLEAR_DISCARD_COLOR_6 or
      CLEAR_DISCARD_COLOR_7)

## /

const
  CLEAR_DISCARD_MASK* = (0'u64 or CLEAR_DISCARD_COLOR_MASK or
      CLEAR_DISCARD_DEPTH or CLEAR_DISCARD_STENCIL)

## /

const
  DEBUG_NONE* = (0x00000000) ## !< No debug.
  DEBUG_WIREFRAME* = (0x00000001) ## !< Enable wireframe for all primitives.
  DEBUG_IFH* = (0x00000002) ## !< Enable infinitely fast hardware test. No draw calls will be submitted to driver. It’s useful when profiling to quickly assess bottleneck between CPU and GPU.
  DEBUG_STATS* = (0x00000004) ## !< Enable statistics display.
  DEBUG_TEXT* = (0x00000008) ## !< Enable debug text display.
  DEBUG_PROFILER* = (0x00000010) ## !< Enable profiler.

## /

const
  BUFFER_NONE* = (0x00000000) ## !<

## /

const
  BUFFER_COMPUTE_FORMAT_8x1* = (0x00000001) ## !< 1 8-bit value
  BUFFER_COMPUTE_FORMAT_8x2* = (0x00000002) ## !< 2 8-bit values
  BUFFER_COMPUTE_FORMAT_8x4* = (0x00000003) ## !< 4 8-bit values
  BUFFER_COMPUTE_FORMAT_16x1* = (0x00000004) ## !< 1 16-bit value
  BUFFER_COMPUTE_FORMAT_16x2* = (0x00000005) ## !< 2 16-bit values
  BUFFER_COMPUTE_FORMAT_16x4* = (0x00000006) ## !< 4 16-bit values
  BUFFER_COMPUTE_FORMAT_32x1* = (0x00000007) ## !< 1 32-bit value
  BUFFER_COMPUTE_FORMAT_32x2* = (0x00000008) ## !< 2 32-bit values
  BUFFER_COMPUTE_FORMAT_32x4* = (0x00000009) ## !< 4 32-bit values
  BUFFER_COMPUTE_FORMAT_SHIFT* = 0
  BUFFER_COMPUTE_FORMAT_MASK* = (0x0000000F) ## !<

## /

const
  BUFFER_COMPUTE_TYPE_INT* = (0x00000010) ## !< Type `int`.
  BUFFER_COMPUTE_TYPE_UINT* = (0x00000020) ## !< Type `uint`.
  BUFFER_COMPUTE_TYPE_FLOAT* = (0x00000030) ## !< Type `float`.
  BUFFER_COMPUTE_TYPE_SHIFT* = 4
  BUFFER_COMPUTE_TYPE_MASK* = (0x00000030) ## !<

## /

const
  BUFFER_COMPUTE_READ* = (0x00000100) ## !< Buffer will be read by shader.
  BUFFER_COMPUTE_WRITE* = (0x00000200) ## !< Buffer will be used for writing.
  BUFFER_DRAW_INDIRECT* = (0x00000400) ## !< Buffer will be used for storing draw indirect commands.
  BUFFER_ALLOW_RESIZE* = (0x00000800) ## !< Allow dynamic index/vertex buffer resize during update.
  BUFFER_INDEX32* = (0x00001000) ## !< Index buffer contains 32-bit indices.

## /

const
  BUFFER_COMPUTE_READ_WRITE* = (
    0'u64 or BUFFER_COMPUTE_READ or BUFFER_COMPUTE_WRITE)

## / Texture creation flags.

const
  TEXTURE_NONE* = (0x0000000000000000'u64) ## !<
  TEXTURE_MSAA_SAMPLE* = (0x0000000800000000'u64) ## !< Texture will be used for MSAA sampling.
  TEXTURE_RT* = (0x0000001000000000'u64) ## !< Render target no MSAA.
  TEXTURE_RT_MSAA_X2* = (0x0000002000000000'u64) ## !< Render target MSAAx2 mode.
  TEXTURE_RT_MSAA_X4* = (0x0000003000000000'u64) ## !< Render target MSAAx4 mode.
  TEXTURE_RT_MSAA_X8* = (0x0000004000000000'u64) ## !< Render target MSAAx8 mode.
  TEXTURE_RT_MSAA_X16* = (0x0000005000000000'u64) ## !< Render target MSAAx16 mode.
  TEXTURE_RT_MSAA_SHIFT* = 36
  TEXTURE_RT_MSAA_MASK* = (0x0000007000000000'u64) ## !<
  TEXTURE_RT_WRITE_ONLY* = (0x0000008000000000'u64) ## !< Render target will be used for writing only.
  TEXTURE_RT_MASK* = (0x000000F000000000'u64) ## !<
  TEXTURE_COMPUTE_WRITE* = (0x0000100000000000'u64) ## !< Texture will be used for compute write.
  TEXTURE_SRGB* = (0x0000200000000000'u64) ## !< Sample texture as sRGB.
  TEXTURE_BLIT_DST* = (0x0000400000000000'u64) ## !< Texture will be used as blit destination.
  TEXTURE_READ_BACK* = (0x0000800000000000'u64) ## !< Texture will be used for read back from GPU.

## / Sampler flags.

const
  SAMPLER_NONE* = (0x00000000) ## !<
  SAMPLER_U_MIRROR* = (0x00000001) ## !< Wrap U mode: Mirror
  SAMPLER_U_CLAMP* = (0x00000002) ## !< Wrap U mode: Clamp
  SAMPLER_U_BORDER* = (0x00000003) ## !< Wrap U mode: Border
  SAMPLER_U_SHIFT* = 0
  SAMPLER_U_MASK* = (0x00000003) ## !<
  SAMPLER_V_MIRROR* = (0x00000004) ## !< Wrap V mode: Mirror
  SAMPLER_V_CLAMP* = (0x00000008) ## !< Wrap V mode: Clamp
  SAMPLER_V_BORDER* = (0x0000000C) ## !< Wrap V mode: Border
  SAMPLER_V_SHIFT* = 2
  SAMPLER_V_MASK* = (0x0000000C) ## !<
  SAMPLER_W_MIRROR* = (0x00000010) ## !< Wrap W mode: Mirror
  SAMPLER_W_CLAMP* = (0x00000020) ## !< Wrap W mode: Clamp
  SAMPLER_W_BORDER* = (0x00000030) ## !< Wrap W mode: Border
  SAMPLER_W_SHIFT* = 4
  SAMPLER_W_MASK* = (0x00000030) ## !<
  SAMPLER_MIN_POINT* = (0x00000040) ## !< Min sampling mode: Point
  SAMPLER_MIN_ANISOTROPIC* = (0x00000080) ## !< Min sampling mode: Anisotropic
  SAMPLER_MIN_SHIFT* = 6
  SAMPLER_MIN_MASK* = (0x000000C0) ## !<
  SAMPLER_MAG_POINT* = (0x00000100) ## !< Mag sampling mode: Point
  SAMPLER_MAG_ANISOTROPIC* = (0x00000200) ## !< Mag sampling mode: Anisotropic
  SAMPLER_MAG_SHIFT* = 8
  SAMPLER_MAG_MASK* = (0x00000300) ## !<
  SAMPLER_MIP_POINT* = (0x00000400) ## !< Mip sampling mode: Point
  SAMPLER_MIP_SHIFT* = 10
  SAMPLER_MIP_MASK* = (0x00000400) ## !<
  SAMPLER_COMPARE_LESS* = (0x00010000) ## !< Compare when sampling depth texture: less.
  SAMPLER_COMPARE_LEQUAL* = (0x00020000) ## !< Compare when sampling depth texture: less or equal.
  SAMPLER_COMPARE_EQUAL* = (0x00030000) ## !< Compare when sampling depth texture: equal.
  SAMPLER_COMPARE_GEQUAL* = (0x00040000) ## !< Compare when sampling depth texture: greater or equal.
  SAMPLER_COMPARE_GREATER* = (0x00050000) ## !< Compare when sampling depth texture: greater.
  SAMPLER_COMPARE_NOTEQUAL* = (0x00060000) ## !< Compare when sampling depth texture: not equal.
  SAMPLER_COMPARE_NEVER* = (0x00070000) ## !< Compare when sampling depth texture: never.
  SAMPLER_COMPARE_ALWAYS* = (0x00080000) ## !< Compare when sampling depth texture: always.
  SAMPLER_COMPARE_SHIFT* = 16
  SAMPLER_COMPARE_MASK* = (0x000F0000) ## !<
  SAMPLER_SAMPLE_STENCIL* = (0x00100000) ## !< Sample stencil instead of depth.
  SAMPLER_BORDER_COLOR_SHIFT* = 24
  SAMPLER_BORDER_COLOR_MASK* = (0x0F000000) ## !<
  SAMPLER_RESERVED_SHIFT* = 28
  SAMPLER_RESERVED_MASK* = (0xF0000000) ## !<

## /

template SAMPLER_BORDER_COLOR*(index: untyped): untyped =
  ((index shl SAMPLER_BORDER_COLOR_SHIFT) and
      SAMPLER_BORDER_COLOR_MASK)

## /

const
  SAMPLER_BITS_MASK* = (0'u64 or SAMPLER_U_MASK or SAMPLER_V_MASK or
      SAMPLER_W_MASK or SAMPLER_MIN_MASK or SAMPLER_MAG_MASK or
      SAMPLER_MIP_MASK or SAMPLER_COMPARE_MASK)

## /

const
  RESET_NONE* = (0x00000000) ## !< No reset flags.
  RESET_FULLSCREEN* = (0x00000001) ## !< Not supported yet.
  RESET_FULLSCREEN_SHIFT* = 0
  RESET_FULLSCREEN_MASK* = (0x00000001) ## !< Fullscreen bit mask.
  RESET_MSAA_X2* = (0x00000010) ## !< Enable 2x MSAA.
  RESET_MSAA_X4* = (0x00000020) ## !< Enable 4x MSAA.
  RESET_MSAA_X8* = (0x00000030) ## !< Enable 8x MSAA.
  RESET_MSAA_X16* = (0x00000040) ## !< Enable 16x MSAA.
  RESET_MSAA_SHIFT* = 4
  RESET_MSAA_MASK* = (0x00000070) ## !< MSAA mode bit mask.
  RESET_VSYNC* = (0x00000080) ## !< Enable V-Sync.
  RESET_MAXANISOTROPY* = (0x00000100) ## !< Turn on/off max anisotropy.
  RESET_CAPTURE* = (0x00000200) ## !< Begin screen capture.
  RESET_FLUSH_AFTER_RENDER* = (0x00002000) ## !< Flush rendering after submitting to GPU.
  RESET_FLIP_AFTER_RENDER* = (0x00004000) ## !< This flag  specifies where flip occurs. Default behavior is that flip occurs before rendering new frame. This flag only has effect when `CONFIG_MULTITHREADED=0`.
  RESET_SRGB_BACKBUFFER* = (0x00008000) ## !< Enable sRGB backbuffer.
  RESET_HDR10* = (0x00010000) ## !< Enable HDR10 rendering.
  RESET_HIDPI* = (0x00020000) ## !< Enable HiDPI rendering.
  RESET_DEPTH_CLAMP* = (0x00040000) ## !< Enable depth clamp.
  RESET_SUSPEND* = (0x00080000) ## !< Suspend rendering.
  RESET_RESERVED_SHIFT* = 31
  RESET_RESERVED_MASK* = (0x80000000) ## !< Internal bits mask.

## /

const
  CAPS_ALPHA_TO_COVERAGE* = (0x0000000000000001'u64) ## !< Alpha to coverage is supported.
  CAPS_BLEND_INDEPENDENT* = (0x0000000000000002'u64) ## !< Blend independent is supported.
  CAPS_COMPUTE* = (0x0000000000000004'u64) ## !< Compute shaders are supported.
  CAPS_CONSERVATIVE_RASTER* = (0x0000000000000008'u64) ## !< Conservative rasterization is supported.
  CAPS_DRAW_INDIRECT* = (0x0000000000000010'u64) ## !< Draw indirect is supported.
  CAPS_FRAGMENT_DEPTH* = (0x0000000000000020'u64) ## !< Fragment depth is accessible in fragment shader.
  CAPS_FRAGMENT_ORDERING* = (0x0000000000000040'u64) ## !< Fragment ordering is available in fragment shader.
  CAPS_GRAPHICS_DEBUGGER* = (0x0000000000000080'u64) ## !< Graphics debugger is present.
  CAPS_HDR10* = (0x0000000000000100'u64) ## !< HDR10 rendering is supported.
  CAPS_HIDPI* = (0x0000000000000400'u64) ## !< HiDPI rendering is supported.
  CAPS_INDEX32* = (0x0000000000000800'u64) ## !< 32-bit indices are supported.
  CAPS_INSTANCING* = (0x0000000000001000'u64) ## !< Instancing is supported.
  CAPS_OCCLUSION_QUERY* = (0x0000000000002000'u64) ## !< Occlusion query is supported.
  CAPS_RENDERER_MULTITHREADED* = (0x0000000000004000'u64) ## !< Renderer is on separate thread.
  CAPS_SWAP_CHAIN* = (0x0000000000008000'u64) ## !< Multiple windows are supported.
  CAPS_TEXTURE_2D_ARRAY* = (0x0000000000010000'u64) ## !< 2D texture array is supported.
  CAPS_TEXTURE_3D* = (0x0000000000020000'u64) ## !< 3D textures are supported.
  CAPS_TEXTURE_BLIT* = (0x0000000000040000'u64) ## !< Texture blit is supported.
  CAPS_TEXTURE_COMPARE_ALL* = (0x0000000000180000'u64) ## !< All texture compare modes are supported.
  CAPS_TEXTURE_COMPARE_LEQUAL* = (0x0000000000100000'u64) ## !< Texture compare less equal mode is supported.
  CAPS_TEXTURE_CUBE_ARRAY* = (0x0000000000200000'u64) ## !< Cubemap texture array is supported.
  CAPS_TEXTURE_DIRECT_ACCESS* = (0x0000000000400000'u64) ## !< CPU direct access to GPU texture memory.
  CAPS_TEXTURE_READ_BACK* = (0x0000000000800000'u64) ## !< Read-back texture is supported.
  CAPS_VERTEX_ATTRIB_HALF* = (0x0000000001000000'u64) ## !< Vertex attribute half-float is supported.
  CAPS_VERTEX_ATTRIB_UINT10* = (0x0000000002000000'u64) ## !< Vertex attribute 10_10_10_2 is supported.
  CAPS_VERTEX_ID* = (0x0000000004000000'u64) ## !< Rendering with VertexID only is supported.

## /

const
  CAPS_FORMAT_TEXTURE_NONE* = (0x00000000) ## !< Texture format is not supported.
  CAPS_FORMAT_TEXTURE_2D* = (0x00000001) ## !< Texture format is supported.
  CAPS_FORMAT_TEXTURE_2D_SRGB* = (0x00000002) ## !< Texture as sRGB format is supported.
  CAPS_FORMAT_TEXTURE_2D_EMULATED* = (0x00000004) ## !< Texture format is emulated.
  CAPS_FORMAT_TEXTURE_3D* = (0x00000008) ## !< Texture format is supported.
  CAPS_FORMAT_TEXTURE_3D_SRGB* = (0x00000010) ## !< Texture as sRGB format is supported.
  CAPS_FORMAT_TEXTURE_3D_EMULATED* = (0x00000020) ## !< Texture format is emulated.
  CAPS_FORMAT_TEXTURE_CUBE* = (0x00000040) ## !< Texture format is supported.
  CAPS_FORMAT_TEXTURE_CUBE_SRGB* = (0x00000080) ## !< Texture as sRGB format is supported.
  CAPS_FORMAT_TEXTURE_CUBE_EMULATED* = (0x00000100) ## !< Texture format is emulated.
  CAPS_FORMAT_TEXTURE_VERTEX* = (0x00000200) ## !< Texture format can be used from vertex shader.
  CAPS_FORMAT_TEXTURE_IMAGE* = (0x00000400) ## !< Texture format can be used as image from compute shader.
  CAPS_FORMAT_TEXTURE_FRAMEBUFFER* = (0x00000800) ## !< Texture format can be used as frame buffer.
  CAPS_FORMAT_TEXTURE_FRAMEBUFFER_MSAA* = (0x00001000) ## !< Texture format can be used as MSAA frame buffer.
  CAPS_FORMAT_TEXTURE_MSAA* = (0x00002000) ## !< Texture can be sampled as MSAA.
  CAPS_FORMAT_TEXTURE_MIP_AUTOGEN* = (0x00004000) ## !< Texture format supports auto-generated mips.

## /

const
  VIEW_NONE* = (0x00000000) ## !<
  VIEW_STEREO* = (0x00000001) ## !< View will be rendered in stereo mode.

## /

const
  SUBMIT_EYE_LEFT* = (0x00000001) ## !< Submit to left eye.
  SUBMIT_EYE_RIGHT* = (0x00000002) ## !< Submit to right eye.
  SUBMIT_EYE_MASK* = (0x00000003) ## !<
  SUBMIT_EYE_FIRST* = SUBMIT_EYE_LEFT
  SUBMIT_RESERVED_SHIFT* = 7
  SUBMIT_RESERVED_MASK* = (0x00000080) ## !< Internal bits mask.

## /

const
  RESOLVE_NONE* = (0x00000000) ## !< No resolve flags.
  RESOLVE_AUTO_GEN_MIPS* = (0x00000001) ## !< Auto-generate mip maps on resolve.

## /

const
  PCI_ID_NONE* = (0x00000000) ## !< Autoselect adapter.
  PCI_ID_SOFTWARE_RASTERIZER* = (0x00000001) ## !< Software rasterizer.
  PCI_ID_AMD* = (0x00001002) ## !< AMD adapter.
  PCI_ID_INTEL* = (0x00008086) ## !< Intel adapter.
  PCI_ID_NVIDIA* = (0x000010DE) ## !< nVidia adapter.

## /

const
  CUBE_MAP_POSITIVE_X* = (0x00000000) ## !< Cubemap +x.
  CUBE_MAP_NEGATIVE_X* = (0x00000001) ## !< Cubemap -x.
  CUBE_MAP_POSITIVE_Y* = (0x00000002) ## !< Cubemap +y.
  CUBE_MAP_NEGATIVE_Y* = (0x00000003) ## !< Cubemap -y.
  CUBE_MAP_POSITIVE_Z* = (0x00000004) ## !< Cubemap +z.
  CUBE_MAP_NEGATIVE_Z* = (0x00000005) ## !< Cubemap -z.
