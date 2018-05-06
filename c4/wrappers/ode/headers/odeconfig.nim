when defined(__aarch64__):
  type
    dint64* = int64_t
    duint64* = uint64_t
    dint32* = int32_t
    duint32* = uint32_t
    dint16* = int16_t
    duint16* = uint16_t
    dint8* = int8_t
    duint8* = uint8_t
    dintptr* = intptr_t
    duintptr* = uintptr_t
    ddiffint* = ptrdiff_t
    dsizeint* = csize
elif defined(_M_IA64) or defined(__ia64__) or defined(_M_AMD64) or defined(__x86_64__):
  const X86_64_SYSTEM* = 1
  type
    dint32* = cint
    duint32* = cuint
    dint16* = cshort
    duint16* = cushort
    dint8* = cchar
    duint8* = cuchar
    dintptr* = dint64
    duintptr* = duint64
    ddiffint* = dint64
    dsizeint* = duint64
else:
  type
    dint32* = cint
    duint32* = cuint
    dint16* = cshort
    duint16* = cushort
    dint8* = cchar
    duint8* = cuchar
    dintptr* = dint32
    duintptr* = duint32
    ddiffint* = dint32
    dsizeint* = duint32

when defined(dSINGLE):
  const
    dInfinity* = (1.0 div 0.0).float
    dNaN* = (dInfinity - dInfinity).float
else:
  const
    dInfinity* = (1.0 div 0.0)
    dNaN* = (dInfinity - dInfinity)
