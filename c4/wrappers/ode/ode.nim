# /*************************************************************************
#  *                                                                       *
#  * Open Dynamics Engine, Copyright (C) 2001,2002 Russell L. Smith.       *
#  * All rights reserved.  Email: russ@q12.org   Web: www.q12.org          *
#  *                                                                       *
#  * This library is free software; you can redistribute it and/or         *
#  * modify it under the terms of EITHER:                                  *
#  *   (1) The GNU Lesser General Public License as published by the Free  *
#  *       Software Foundation; either version 2.1 of the License, or (at  *
#  *       your option) any later version. The text of the GNU Lesser      *
#  *       General Public License is included with this library in the     *
#  *       file LICENSE.TXT.                                               *
#  *   (2) The BSD-style license that is included with this library in     *
#  *       the file LICENSE-BSD.TXT.                                       *
#  *                                                                       *
#  * This library is distributed in the hope that it will be useful,       *
#  * but WITHOUT ANY WARRANTY; without even the implied warranty of        *
#  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the files    *
#  * LICENSE.TXT and LICENSE-BSD.TXT for more details.                     *
#  *                                                                       *
#  *************************************************************************/

when defined(windows):
  const lib* = "ode.dll"
elif defined(macosx):
  const lib* = "ode.dylib"
elif defined(unix):
  const lib* = "libode.so"
else:
  {.error: "Unsupported platform".}

# precision.h
type
  Precision* = enum
    single, double

when defined(dIDEDOUBLE):
  const precision = Precision.double
elif defined(dIDESINGLE):
  const precision = Precision.single
else:
  const precision = Precision.single

type
  ptrdiff_t* {.importc: "ptrdiff_t", header: "<stddef.h>".} = int
  time_t* {.importc: "time_t", header: "<time.h>".} = int


# ---- types ----
# TODO: x32 not supported
# when compileOption("cpu", "i386"):
#   type
#     dint32* = cint
#     duint32* = cuint
#     dint16* = cshort
#     duint16* = cushort
#     dint8* = cchar
#     duint8* = cuchar
#     dintptr* = dint32
#     duintptr* = duint32
#     ddiffint* = dint32
#     dsizeint* = duint32
# else:
# const X86_64_SYSTEM* = 1
type
  dint64* = clonglong
  duint64* = culonglong

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

when precision == Precision.single:
  type dReal* = cfloat
else:
  type dReal* = cdouble

when defined(dTRIMESH_16BIT_INDICES):
  when dTRIMESH_GIMPACT:
    type dTriIndex* = duint32
  else:
    type dTriIndex* = duint16
else:
  type dTriIndex* = duint32

type
  dxWorld* {.bycopy.} = object
  dxSpace* {.bycopy.} = object
  dxBody* {.bycopy.} = object
  dxGeom* {.bycopy.} = object
  dxJoint* {.bycopy.} = object
  dxJointNode* {.bycopy.} = object
  dxJointGroup* {.bycopy.} = object
  dxWorldProcessThreadingManager* {.bycopy.} = object
  
  # TODO: use just `pointer`?
  dWorldID* = ptr dxWorld
  dSpaceID* = ptr dxSpace
  dBodyID* = ptr dxBody
  dGeomID* = ptr dxGeom
  dJointID* = ptr dxJoint
  dJointGroupID* = ptr dxJointGroup
  dWorldStepThreadingManagerID* = ptr dxWorldProcessThreadingManager

  dJointType* = enum
    dJointTypeNone = 0, dJointTypeBall, dJointTypeHinge, dJointTypeSlider,
    dJointTypeContact, dJointTypeUniversal, dJointTypeHinge2, dJointTypeFixed,
    dJointTypeNull, dJointTypeAMotor, dJointTypeLMotor, dJointTypePlane2D,
    dJointTypePR, dJointTypePU, dJointTypePiston, dJointTypeDBall, dJointTypeDHinge,
    dJointTypeTransmission
  
  dVector3* = array[4, dReal]
  dVector4* = array[4, dReal]
  dMatrix3* = array[4 * 3, dReal]
  dMatrix4* = array[4 * 4, dReal]
  dMatrix6* = array[8 * 6, dReal]
  dQuaternion* = array[4, dReal]

  dJointFeedback* {.bycopy.} = object
    f1*: dVector3
    t1*: dVector3
    f2*: dVector3
    t2*: dVector3

  dMessageFunction* = proc (errnum: cint; msg: cstring) {.varargs, cdecl.}

  dInitODEFlags* {.size: sizeof(cint).} = enum
    dInitFlagManualThreadCleanup = 0x00000001

  dAllocateODEDataFlags* {.size: sizeof(cint).} = enum
    dAllocateFlagBasicData = 0,
    dAllocateFlagCollisionData = 0x00000001,
    dAllocateMaskAll = cint.high  # not 0

  dSurfaceParameters* {.bycopy.} = object
    mode*: cint
    mu*: dReal
    mu2*: dReal
    rho*: dReal
    rho2*: dReal
    rhoN*: dReal
    bounce*: dReal
    bounce_vel*: dReal
    soft_erp*: dReal
    soft_cfm*: dReal
    motion1*: dReal
    motion2*: dReal
    motionN*: dReal
    slip1*: dReal
    slip2*: dReal

  dContactGeom* {.bycopy.} = object
    pos*: dVector3
    normal*: dVector3
    depth*: dReal
    g1*: dGeomID
    g2*: dGeomID
    side1*: cint
    side2*: cint

  dContact* {.bycopy.} = object
    surface*: dSurfaceParameters
    geom*: dContactGeom
    fdir1*: dVector3
  
  dStopwatch* {.bycopy.} = object
    time*: cdouble
    cc*: array[2, culong]

  dMass* {.bycopy.} = object
    mass*: dReal
    c*: dVector3
    I*: dMatrix3

  dxThreadingImplementation* {.bycopy.} = object
  
  dThreadingImplementationID* = ptr dxThreadingImplementation
  dmutexindex_t* = cuint
  dxMutexGroup* {.bycopy.} = object
  
  dMutexGroupID* = ptr dxMutexGroup
  dMutexGroupAllocFunction* = proc (impl: dThreadingImplementationID; Mutex_count: dmutexindex_t; Mutex_names_ptr: cstringArray): dMutexGroupID
  dMutexGroupFreeFunction* = proc (impl: dThreadingImplementationID; mutex_group: dMutexGroupID)
  dMutexGroupMutexLockFunction* = proc (impl: dThreadingImplementationID; mutex_group: dMutexGroupID; mutex_index: dmutexindex_t)
  dMutexGroupMutexUnlockFunction* = proc (impl: dThreadingImplementationID; mutex_group: dMutexGroupID; mutex_index: dmutexindex_t)
  dxCallReleasee* {.bycopy.} = object
  dCallReleaseeID* = ptr dxCallReleasee
  dxCallWait* {.bycopy.} = object
  dCallWaitID* = ptr dxCallWait
  ddependencycount_t* = csize
  ddependencychange_t* = ptrdiff_t
  dcallindex_t* = csize
  dThreadedCallFunction* = proc (call_context: pointer; instance_index: dcallindex_t; this_releasee: dCallReleaseeID): cint
  dThreadedWaitTime* {.bycopy.} = object
    wait_sec*: time_t
    wait_nsec*: culong
  dThreadedCallWaitAllocFunction* = proc (impl: dThreadingImplementationID): dCallWaitID
  dThreadedCallWaitResetFunction* = proc (impl: dThreadingImplementationID; call_wait: dCallWaitID)
  dThreadedCallWaitFreeFunction* = proc (impl: dThreadingImplementationID; call_wait: dCallWaitID)
  dThreadedCallPostFunction* = proc (impl: dThreadingImplementationID; out_summary_fault: ptr cint; out_post_releasee: ptr dCallReleaseeID; dependencies_count: ddependencycount_t; dependent_releasee: dCallReleaseeID; call_wait: dCallWaitID; call_func: ptr dThreadedCallFunction; call_context: pointer; instance_index: dcallindex_t; call_name: cstring)
  dThreadedCallDependenciesCountAlterFunction* = proc (impl: dThreadingImplementationID; target_releasee: dCallReleaseeID;dependencies_count_change: ddependencychange_t)
  dThreadedCallWaitFunction* = proc (impl: dThreadingImplementationID; out_wait_status: ptr cint; call_wait: dCallWaitID;timeout_time_ptr: ptr dThreadedWaitTime; wait_name: cstring)
  dThreadingImplThreadCountRetrieveFunction* = proc (impl: dThreadingImplementationID): cuint
  dThreadingImplResourcesForCallsPreallocateFunction* = proc (impl: dThreadingImplementationID; max_simultaneous_calls_estimate: ddependencycount_t): cint
  dThreadingFunctionsInfo* {.bycopy.} = object
    struct_size*: cuint
    alloc_mutex_group*: ptr dMutexGroupAllocFunction
    free_mutex_group*: ptr dMutexGroupFreeFunction
    lock_group_mutex*: ptr dMutexGroupMutexLockFunction
    unlock_group_mutex*: ptr dMutexGroupMutexUnlockFunction
    alloc_call_wait*: ptr dThreadedCallWaitAllocFunction
    reset_call_wait*: ptr dThreadedCallWaitResetFunction
    free_call_wait*: ptr dThreadedCallWaitFreeFunction
    post_call*: ptr dThreadedCallPostFunction
    alter_call_dependencies_count*: ptr dThreadedCallDependenciesCountAlterFunction
    wait_call*: ptr dThreadedCallWaitFunction
    retrieve_thread_count*: ptr dThreadingImplThreadCountRetrieveFunction
    preallocate_resources_for_calls*: ptr dThreadingImplResourcesForCallsPreallocateFunction

  dWorldStepReserveInfo* {.bycopy.} = object
    struct_size*: cuint
    reserve_factor*: cfloat
    reserve_minimum*: cuint

  dWorldStepMemoryFunctionsInfo* {.bycopy.} = object
    struct_size*: cuint
    alloc_block*: proc (block_size: csize): pointer
    shrink_block*: proc (block_pointer: pointer; block_current_size: csize; block_smaller_size: csize): pointer
    free_block*: proc (block_pointer: pointer; block_current_size: csize)
    
  dNearCallback* = proc (data: pointer; o1: dGeomID; o2: dGeomID)

  dxHeightfieldData* {.bycopy.} = object
  dHeightfieldDataID* = ptr dxHeightfieldData
  dHeightfieldGetHeight* = proc (p_user_data: pointer; x: cint; z: cint): dReal
  dGetAABBFn* = proc (a2: dGeomID; aabb: array[6, dReal])
  dColliderFn* = proc (o1: dGeomID; o2: dGeomID; flags: cint; contact: ptr dContactGeom;  skip: cint): cint
  dGetColliderFnFn* = proc (num: cint): ptr dColliderFn
  dGeomDtorFn* = proc (o: dGeomID)
  dAABBTestFn* = proc (o1: dGeomID; o2: dGeomID; aabb: array[6, dReal]): cint
  dGeomClass* {.bycopy.} = object
    bytes*: cint
    collider*: ptr dGetColliderFnFn
    aabb*: ptr dGetAABBFn
    aabb_test*: ptr dAABBTestFn
    dtor*: ptr dGeomDtorFn

  dxThreadingThreadPool* {.bycopy.} = object
  dThreadingThreadPoolID* = ptr dxThreadingThreadPool
  dThreadReadyToServeCallback* = proc (callback_context: pointer)


# ---- const ----
when precision == Precision.single:
  const
    dInfinity* = (1.0 / 0.0).float
    dNaN* = (dInfinity - dInfinity).float
else:
  const
    dInfinity* = (1.0 / 0.0)
    dNaN* = (dInfinity - dInfinity)

const
  d_ERR_UNKNOWN* = 0
  d_ERR_IASSERT* = 1
  d_ERR_UASSERT* = 2
  d_ERR_LCP* = 3
  
  dParamLoStop* = 0
  dParamHiStop* = 1
  dParamVel* = 2
  dParamLoVel* = 3
  dParamHiVel* = 4
  dParamFMax* = 5
  dParamFudgeFactor* = 6
  dParamBounce* = 7
  dParamCFM* = 8
  dParamStopERP* = 9
  dParamStopCFM* = 10
  dParamSuspensionERP* = 11
  dParamSuspensionCFM* = 12
  dParamERP* = 13
  dParamsInGroup* = 14
  dParamGroup1* = 0x00000000
  dParamLoStop1* = 0x00000000
  dParamHiStop1* = 1
  dParamVel1* = 2
  dParamLoVel1* = 3
  dParamHiVel1* = 4
  dParamFMax1* = 5
  dParamFudgeFactor1* = 6
  dParamBounce1* = 7
  dParamCFM1* = 8
  dParamStopERP1* = 9
  dParamStopCFM1* = 10
  dParamSuspensionERP1* = 11
  dParamSuspensionCFM1* = 12
  dParamERP1* = 13
  dParamGroup2* = 0x00000100
  dParamLoStop2* = 0x00000100
  dParamHiStop2* = 257
  dParamVel2* = 258
  dParamLoVel2* = 259
  dParamHiVel2* = 260
  dParamFMax2* = 261
  dParamFudgeFactor2* = 262
  dParamBounce2* = 263
  dParamCFM2* = 264
  dParamStopERP2* = 265
  dParamStopCFM2* = 266
  dParamSuspensionERP2* = 267
  dParamSuspensionCFM2* = 268
  dParamERP2* = 269
  dParamGroup3* = 0x00000200
  dParamLoStop3* = 0x00000200
  dParamHiStop3* = 513
  dParamVel3* = 514
  dParamLoVel3* = 515
  dParamHiVel3* = 516
  dParamFMax3* = 517
  dParamFudgeFactor3* = 518
  dParamBounce3* = 519
  dParamCFM3* = 520
  dParamStopERP3* = 521
  dParamStopCFM3* = 522
  dParamSuspensionERP3* = 523
  dParamSuspensionCFM3* = 524
  dParamERP3* = 525
  dParamGroup* = 0x00000100

  dAMotorUser* = 0
  dAMotorEuler* = 1

  dTransmissionParallelAxes* = 0
  dTransmissionIntersectingAxes* = 1
  dTransmissionChainDrive* = 2

  dContactMu2* = 0x00000001
  dContactAxisDep* = 0x00000001
  dContactFDir1* = 0x00000002
  dContactBounce* = 0x00000004
  dContactSoftERP* = 0x00000008
  dContactSoftCFM* = 0x00000010
  dContactMotion1* = 0x00000020
  dContactMotion2* = 0x00000040
  dContactMotionN* = 0x00000080
  dContactSlip1* = 0x00000100
  dContactSlip2* = 0x00000200
  dContactRolling* = 0x00000400
  dContactApprox0* = 0x00000000
  dContactApprox1_1* = 0x00001000
  dContactApprox1_2* = 0x00002000
  dContactApprox1_N* = 0x00004000
  dContactApprox1* = 0x00007000

  dWORLDSTEP_THREADCOUNT_UNLIMITED* = 0
  dWORLDSTEP_RESERVEFACTOR_DEFAULT* = 1.2
  dWORLDSTEP_RESERVESIZE_DEFAULT* = 65536

  dSAP_AXES_XYZ* = ((0) or (1 shl 2) or (2 shl 4))
  dSAP_AXES_XZY* = ((0) or (2 shl 2) or (1 shl 4))
  dSAP_AXES_YXZ* = ((1) or (0 shl 2) or (2 shl 4))
  dSAP_AXES_YZX* = ((1) or (2 shl 2) or (0 shl 4))
  dSAP_AXES_ZXY* = ((2) or (0 shl 2) or (1 shl 4))
  dSAP_AXES_ZYX* = ((2) or (1 shl 2) or (0 shl 4))

  dGeomCommonControlClass* = 0
  dGeomColliderControlClass* = 1
  dGeomCommonAnyControlCode* = 0
  dGeomColliderSetMergeSphereContactsControlCode* = 1
  dGeomColliderGetMergeSphereContactsControlCode* = 2
  dGeomColliderMergeContactsValue_Default* = 0
  dGeomColliderMergeContactsValue_None* = 1
  dGeomColliderMergeContactsValue_Normals* = 2
  dGeomColliderMergeContactsValue_Full* = 3

  CONTACTS_UNIMPORTANT* = 0x80000000
  dMaxUserClasses* = 4
  dSphereClass* = 0
  dBoxClass* = 1
  dCapsuleClass* = 2
  dCylinderClass* = 3
  dPlaneClass* = 4
  dRayClass* = 5
  dConvexClass* = 6
  dGeomTransformClass* = 7
  dTriMeshClass* = 8
  dHeightfieldClass* = 9
  dFirstSpaceClass* = 10
  dSimpleSpaceClass* = dFirstSpaceClass
  dHashSpaceClass* = 11  # TODO Warning: computed const value may be wrong:
  dSweepAndPruneSpaceClass* = 12  # TODO Warning: computed const value may be wrong:
  dQuadTreeSpaceClass* = 13  # TODO Warning: computed const value may be wrong:
  dLastSpaceClass* = dQuadTreeSpaceClass
  dFirstUserClass* = 14  # TODO Warning: computed const value may be wrong:
  dLastUserClass* = dFirstUserClass + dMaxUserClasses - 1
  dGeomNumClasses* = 15  # TODO Warning: computed const value may be wrong:


# ---- procs ----
{.push cdecl, dynlib:lib.}
proc geomMoved*(a2: dGeomID) {.importc: "dGeomMoved".}
proc geomGetBodyNext*(a2: dGeomID): dGeomID {.importc: "dGeomGetBodyNext".}
proc getConfiguration*(): cstring {.importc: "dGetConfiguration".}
proc checkConfiguration*(token: cstring): cint {.importc: "dCheckConfiguration".}

proc setErrorHandler*(fn: ptr dMessageFunction) {.importc: "dSetErrorHandler".}
proc setDebugHandler*(fn: ptr dMessageFunction) {.importc: "dSetDebugHandler".}
proc setMessageHandler*(fn: ptr dMessageFunction) {.importc: "dSetMessageHandler".}
proc getErrorHandler*(): ptr dMessageFunction {.importc: "dGetErrorHandler".}
proc getDebugHandler*(): ptr dMessageFunction {.importc: "dGetDebugHandler".}
proc getMessageHandler*(): ptr dMessageFunction {.importc: "dGetMessageHandler".}

proc error*(num: cint; msg: cstring) {.varargs, importc: "dError".}
proc debug*(num: cint; msg: cstring) {.varargs, importc: "dDebug".}
proc message*(num: cint; msg: cstring) {.varargs, importc: "dMessage".}

proc initODE*() {.importc: "dInitODE".}
proc initODE2*(uiInitFlags: cuint): cint {.importc: "dInitODE2".}
proc allocateODEDataForThread*(uiAllocateFlags: cuint): cint {.importc: "dAllocateODEDataForThread".}
proc cleanupODEAllDataForThread*() {.importc: "dCleanupODEAllDataForThread".}
proc closeODE*() {.importc: "dCloseODE".}

proc safeNormalize3*(a: dVector3): cint {.importc: "dSafeNormalize3".}
proc safeNormalize4*(a: dVector4): cint {.importc: "dSafeNormalize4".}
proc normalize3*(a: dVector3) {.importc: "dNormalize3".}
proc normalize4*(a: dVector4) {.importc: "dNormalize4".}
proc planeSpace*(n: dVector3; p: dVector3; q: dVector3) {.importc: "dPlaneSpace".}
proc orthogonalizeR*(m: dMatrix3): cint {.importc: "dOrthogonalizeR".}

proc setZero*(a: ptr dReal; n: cint) {.importc: "dSetZero".}
proc setValue*(a: ptr dReal; n: cint; value: dReal) {.importc: "dSetValue".}
proc dot*(a: ptr dReal; b: ptr dReal; n: cint): dReal {.importc: "dDot".}
proc multiply0*(A: ptr dReal; B: ptr dReal; C: ptr dReal; p: cint; q: cint; r: cint) {.importc: "dMultiply0".}
proc multiply1*(A: ptr dReal; B: ptr dReal; C: ptr dReal; p: cint; q: cint; r: cint) {.importc: "dMultiply1".}
proc multiply2*(A: ptr dReal; B: ptr dReal; C: ptr dReal; p: cint; q: cint; r: cint) {.importc: "dMultiply2".}
proc factorCholesky*(A: ptr dReal; n: cint): cint {.importc: "dFactorCholesky",dynlib: lib.}
proc solveCholesky*(L: ptr dReal; b: ptr dReal; n: cint) {.importc: "dSolveCholesky",dynlib: lib.}
proc invertPDMatrix*(A: ptr dReal; Ainv: ptr dReal; n: cint): cint {.importc: "dInvertPDMatrix".}
proc isPositiveDefinite*(A: ptr dReal; n: cint): cint {.importc: "dIsPositiveDefinite".}
proc factorLDLT*(A: ptr dReal; d: ptr dReal; n: cint; nskip: cint) {.importc: "dFactorLDLT".}
proc solveL1*(L: ptr dReal; b: ptr dReal; n: cint; nskip: cint) {.importc: "dSolveL1".}
proc solveL1T*(L: ptr dReal; b: ptr dReal; n: cint; nskip: cint) {.importc: "dSolveL1T".}
proc vectorScale*(a: ptr dReal; d: ptr dReal; n: cint) {.importc: "dVectorScale".}
proc solveLDLT*(L: ptr dReal; d: ptr dReal; b: ptr dReal; n: cint; nskip: cint) {.importc: "dSolveLDLT".}
proc LDLTAddTL*(L: ptr dReal; d: ptr dReal; a: ptr dReal; n: cint; nskip: cint) {.importc: "dLDLTAddTL".}
proc LDLTRemove*(A: ptr ptr dReal; p: ptr cint; L: ptr dReal; d: ptr dReal; n1: cint; n2: cint; r: cint; nskip: cint) {.importc: "dLDLTRemove".}
proc removeRowCol*(A: ptr dReal; n: cint; nskip: cint; r: cint) {.importc: "dRemoveRowCol".}

proc stopwatchReset*(a2: ptr dStopwatch) {.importc: "dStopwatchReset".}
proc stopwatchStart*(a2: ptr dStopwatch) {.importc: "dStopwatchStart".}
proc stopwatchStop*(a2: ptr dStopwatch) {.importc: "dStopwatchStop".}
proc stopwatchTime*(a2: ptr dStopwatch): cdouble {.importc: "dStopwatchTime".}
proc timerStart*(description: cstring) {.importc: "dTimerStart".}
proc timerNow*(description: cstring) {.importc: "dTimerNow".}
proc timerEnd*() {.importc: "dTimerEnd".}
proc timerReport*(fout: ptr FILE; average: cint) {.importc: "dTimerReport".}
proc timerTicksPerSecond*(): cdouble {.importc: "dTimerTicksPerSecond".}
proc timerResolution*(): cdouble {.importc: "dTimerResolution".}

proc rSetIdentity*(R: dMatrix3) {.importc: "dRSetIdentity".}
proc rFromAxisAndAngle*(R: dMatrix3; ax: dReal; ay: dReal; az: dReal; angle: dReal) {.importc: "dRFromAxisAndAngle".}
proc rFromEulerAngles*(R: dMatrix3; phi: dReal; theta: dReal; psi: dReal) {.importc: "dRFromEulerAngles".}
proc rFrom2Axes*(R: dMatrix3; ax: dReal; ay: dReal; az: dReal; bx: dReal; by: dReal; bz: dReal) {.importc: "dRFrom2Axes".}
proc rFromZAxis*(R: dMatrix3; ax: dReal; ay: dReal; az: dReal) {.importc: "dRFromZAxis".}
proc qSetIdentity*(q: dQuaternion) {.importc: "dQSetIdentity".}
proc qFromAxisAndAngle*(q: dQuaternion; ax: dReal; ay: dReal; az: dReal; angle: dReal) {.importc: "dQFromAxisAndAngle".}
proc qMultiply0*(qa: dQuaternion; qb: dQuaternion; qc: dQuaternion) {.importc: "dQMultiply0".}
proc qMultiply1*(qa: dQuaternion; qb: dQuaternion; qc: dQuaternion) {.importc: "dQMultiply1".}
proc qMultiply2*(qa: dQuaternion; qb: dQuaternion; qc: dQuaternion) {.importc: "dQMultiply2".}
proc qMultiply3*(qa: dQuaternion; qb: dQuaternion; qc: dQuaternion) {.importc: "dQMultiply3".}
proc rfromQ*(R: dMatrix3; q: dQuaternion) {.importc: "dRfromQ".}
proc qfromR*(q: dQuaternion; R: dMatrix3) {.importc: "dQfromR".}
proc dQfromW*(dq: array[4, dReal]; w: dVector3; q: dQuaternion) {.importc: "dDQfromW".}

proc massCheck*(m: ptr dMass): cint {.importc: "dMassCheck".}
proc massSetZero*(a2: ptr dMass) {.importc: "dMassSetZero".}
proc massSetParameters*(a2: ptr dMass; themass: dReal; cgx: dReal; cgy: dReal; cgz: dReal; I11: dReal; I22: dReal; I33: dReal; I12: dReal; I13: dReal; I23: dReal) {.importc: "dMassSetParameters".}
proc massSetSphere*(a2: ptr dMass; density: dReal; radius: dReal) {.importc: "dMassSetSphere".}
proc massSetSphereTotal*(a2: ptr dMass; total_mass: dReal; radius: dReal) {.importc: "dMassSetSphereTotal".}
proc massSetCapsule*(a2: ptr dMass; density: dReal; direction: cint; radius: dReal; length: dReal) {.importc: "dMassSetCapsule".}
proc massSetCapsuleTotal*(a2: ptr dMass; total_mass: dReal; direction: cint; radius: dReal; length: dReal) {.importc: "dMassSetCapsuleTotal".}
proc massSetCylinder*(a2: ptr dMass; density: dReal; direction: cint; radius: dReal; length: dReal) {.importc: "dMassSetCylinder".}
proc massSetCylinderTotal*(a2: ptr dMass; total_mass: dReal; direction: cint; radius: dReal; length: dReal) {.importc: "dMassSetCylinderTotal".}
proc massSetBox*(a2: ptr dMass; density: dReal; lx: dReal; ly: dReal; lz: dReal) {.importc: "dMassSetBox".}
proc massSetBoxTotal*(a2: ptr dMass; total_mass: dReal; lx: dReal; ly: dReal; lz: dReal) {.importc: "dMassSetBoxTotal".}
proc massSetTrimesh*(a2: ptr dMass; density: dReal; g: dGeomID) {.importc: "dMassSetTrimesh".}
proc massSetTrimeshTotal*(m: ptr dMass; total_mass: dReal; g: dGeomID) {.importc: "dMassSetTrimeshTotal".}
proc massAdjust*(a2: ptr dMass; newmass: dReal) {.importc: "dMassAdjust".}
proc massTranslate*(a2: ptr dMass; x: dReal; y: dReal; z: dReal) {.importc: "dMassTranslate".}
proc massRotate*(a2: ptr dMass; R: dMatrix3) {.importc: "dMassRotate".}
proc massAdd*(a: ptr dMass; b: ptr dMass) {.importc: "dMassAdd".}
proc massSetCappedCylinder*(a: ptr dMass; b: dReal; c: cint; d: dReal; e: dReal) {.importc: "dMassSetCappedCylinder".}
proc massSetCappedCylinderTotal*(a: ptr dMass; b: dReal; c: cint; d: dReal; e: dReal) {.importc: "dMassSetCappedCylinderTotal".}

proc testRand*(): cint {.importc: "dTestRand".}
proc rand*(): culong {.importc: "dRand".}
proc randGetSeed*(): culong {.importc: "dRandGetSeed".}
proc randSetSeed*(s: culong) {.importc: "dRandSetSeed".}
proc randInt*(n: cint): cint {.importc: "dRandInt".}
proc randReal*(): dReal {.importc: "dRandReal".}
proc printMatrix*(A: ptr dReal; n: cint; m: cint; fmt: cstring; f: ptr FILE) {.importc: "dPrintMatrix".}
proc makeRandomVector*(A: ptr dReal; n: cint; range: dReal) {.importc: "dMakeRandomVector".}
proc makeRandomMatrix*(A: ptr dReal; n: cint; m: cint; range: dReal) {.importc: "dMakeRandomMatrix".}
proc clearUpperTriangle*(A: ptr dReal; n: cint) {.importc: "dClearUpperTriangle".}
proc maxDifference*(A: ptr dReal; B: ptr dReal; n: cint; m: cint): dReal {.importc: "dMaxDifference".}
proc maxDifferenceLowerTriangle*(A: ptr dReal; B: ptr dReal; n: cint): dReal {.importc: "dMaxDifferenceLowerTriangle".}

proc worldCreate*(): dWorldID {.importc: "dWorldCreate".}
proc worldDestroy*(world: dWorldID) {.importc: "dWorldDestroy".}
proc worldSetData*(world: dWorldID; data: pointer) {.importc: "dWorldSetData".}
proc worldGetData*(world: dWorldID): pointer {.importc: "dWorldGetData".}
proc worldSetGravity*(a2: dWorldID; x: dReal; y: dReal; z: dReal) {.importc: "dWorldSetGravity".}
proc worldGetGravity*(a2: dWorldID; gravity: dVector3) {.importc: "dWorldGetGravity".}
proc worldSetERP*(a2: dWorldID; erp: dReal) {.importc: "dWorldSetERP".}
proc worldGetERP*(a2: dWorldID): dReal {.importc: "dWorldGetERP".}
proc worldSetCFM*(a2: dWorldID; cfm: dReal) {.importc: "dWorldSetCFM".}
proc worldGetCFM*(a2: dWorldID): dReal {.importc: "dWorldGetCFM".}

proc worldSetStepIslandsProcessingMaxThreadCount*(w: dWorldID; count: cuint) {.importc: "dWorldSetStepIslandsProcessingMaxThreadCount".}
proc worldGetStepIslandsProcessingMaxThreadCount*(w: dWorldID): cuint {.importc: "dWorldGetStepIslandsProcessingMaxThreadCount".}
proc worldUseSharedWorkingMemory*(w: dWorldID; from_world: dWorldID): cint {.importc: "dWorldUseSharedWorkingMemory".}
proc worldCleanupWorkingMemory*(w: dWorldID) {.importc: "dWorldCleanupWorkingMemory".}

proc worldSetStepMemoryReservationPolicy*(w: dWorldID; policyinfo: ptr dWorldStepReserveInfo): cint {.importc: "dWorldSetStepMemoryReservationPolicy".}

proc worldSetStepMemoryManager*(w: dWorldID; memfuncs: ptr dWorldStepMemoryFunctionsInfo): cint {.importc: "dWorldSetStepMemoryManager".}
proc worldSetStepThreadingImplementation*(w: dWorldID; functions_info: ptr dThreadingFunctionsInfo; threading_impl: dThreadingImplementationID) {.importc: "dWorldSetStepThreadingImplementation".}
proc worldStep*(w: dWorldID; stepsize: dReal): cint {.importc: "dWorldStep".}
proc worldQuickStep*(w: dWorldID; stepsize: dReal): cint {.importc: "dWorldQuickStep".}
proc worldImpulseToForce*(a2: dWorldID; stepsize: dReal; ix: dReal; iy: dReal; iz: dReal; force: dVector3) {.importc: "dWorldImpulseToForce".}
proc worldSetQuickStepNumIterations*(a2: dWorldID; num: cint) {.importc: "dWorldSetQuickStepNumIterations".}
proc worldGetQuickStepNumIterations*(a2: dWorldID): cint {.importc: "dWorldGetQuickStepNumIterations".}
proc worldSetQuickStepW*(a2: dWorldID; over_relaxation: dReal) {.importc: "dWorldSetQuickStepW".}
proc worldGetQuickStepW*(a2: dWorldID): dReal {.importc: "dWorldGetQuickStepW".}
proc worldSetContactMaxCorrectingVel*(a2: dWorldID; vel: dReal) {.importc: "dWorldSetContactMaxCorrectingVel".}
proc worldGetContactMaxCorrectingVel*(a2: dWorldID): dReal {.importc: "dWorldGetContactMaxCorrectingVel".}
proc worldSetContactSurfaceLayer*(a2: dWorldID; depth: dReal) {.importc: "dWorldSetContactSurfaceLayer".}
proc worldGetContactSurfaceLayer*(a2: dWorldID): dReal {.importc: "dWorldGetContactSurfaceLayer".}
proc worldGetAutoDisableLinearThreshold*(a2: dWorldID): dReal {.importc: "dWorldGetAutoDisableLinearThreshold".}
proc worldSetAutoDisableLinearThreshold*(a2: dWorldID; linear_average_threshold: dReal) {.importc: "dWorldSetAutoDisableLinearThreshold".}
proc worldGetAutoDisableAngularThreshold*(a2: dWorldID): dReal {.importc: "dWorldGetAutoDisableAngularThreshold".}
proc worldSetAutoDisableAngularThreshold*(a2: dWorldID; angular_average_threshold: dReal) {.importc: "dWorldSetAutoDisableAngularThreshold".}
proc worldGetAutoDisableAverageSamplesCount*(a2: dWorldID): cint {.importc: "dWorldGetAutoDisableAverageSamplesCount".}
proc worldSetAutoDisableAverageSamplesCount*(a2: dWorldID; average_samples_count: cuint) {.importc: "dWorldSetAutoDisableAverageSamplesCount".}
proc worldGetAutoDisableSteps*(a2: dWorldID): cint {.importc: "dWorldGetAutoDisableSteps".}
proc worldSetAutoDisableSteps*(a2: dWorldID; steps: cint) {.importc: "dWorldSetAutoDisableSteps".}
proc worldGetAutoDisableTime*(a2: dWorldID): dReal {.importc: "dWorldGetAutoDisableTime".}
proc worldSetAutoDisableTime*(a2: dWorldID; time: dReal) {.importc: "dWorldSetAutoDisableTime".}
proc worldGetAutoDisableFlag*(a2: dWorldID): cint {.importc: "dWorldGetAutoDisableFlag".}
proc worldSetAutoDisableFlag*(a2: dWorldID; do_auto_disable: cint) {.importc: "dWorldSetAutoDisableFlag".}
proc worldGetLinearDampingThreshold*(w: dWorldID): dReal {.importc: "dWorldGetLinearDampingThreshold".}
proc worldSetLinearDampingThreshold*(w: dWorldID; threshold: dReal) {.importc: "dWorldSetLinearDampingThreshold".}
proc worldGetAngularDampingThreshold*(w: dWorldID): dReal {.importc: "dWorldGetAngularDampingThreshold".}
proc worldSetAngularDampingThreshold*(w: dWorldID; threshold: dReal) {.importc: "dWorldSetAngularDampingThreshold".}
proc worldGetLinearDamping*(w: dWorldID): dReal {.importc: "dWorldGetLinearDamping".}
proc worldSetLinearDamping*(w: dWorldID; scale: dReal) {.importc: "dWorldSetLinearDamping".}
proc worldGetAngularDamping*(w: dWorldID): dReal {.importc: "dWorldGetAngularDamping".}
proc worldSetAngularDamping*(w: dWorldID; scale: dReal) {.importc: "dWorldSetAngularDamping".}
proc worldSetDamping*(w: dWorldID; linear_scale: dReal; angular_scale: dReal) {.importc: "dWorldSetDamping".}
proc worldGetMaxAngularSpeed*(w: dWorldID): dReal {.importc: "dWorldGetMaxAngularSpeed".}
proc worldSetMaxAngularSpeed*(w: dWorldID; max_speed: dReal) {.importc: "dWorldSetMaxAngularSpeed".}
proc bodyGetAutoDisableLinearThreshold*(a2: dBodyID): dReal {.importc: "dBodyGetAutoDisableLinearThreshold".}
proc bodySetAutoDisableLinearThreshold*(a2: dBodyID; linear_average_threshold: dReal) {.importc: "dBodySetAutoDisableLinearThreshold".}
proc bodyGetAutoDisableAngularThreshold*(a2: dBodyID): dReal {.importc: "dBodyGetAutoDisableAngularThreshold".}
proc bodySetAutoDisableAngularThreshold*(a2: dBodyID; angular_average_threshold: dReal) {.importc: "dBodySetAutoDisableAngularThreshold".}
proc bodyGetAutoDisableAverageSamplesCount*(a2: dBodyID): cint {.importc: "dBodyGetAutoDisableAverageSamplesCount".}
proc bodySetAutoDisableAverageSamplesCount*(a2: dBodyID; average_samples_count: cuint) {.importc: "dBodySetAutoDisableAverageSamplesCount".}
proc bodyGetAutoDisableSteps*(a2: dBodyID): cint {.importc: "dBodyGetAutoDisableSteps".}
proc bodySetAutoDisableSteps*(a2: dBodyID; steps: cint) {.importc: "dBodySetAutoDisableSteps".}
proc bodyGetAutoDisableTime*(a2: dBodyID): dReal {.importc: "dBodyGetAutoDisableTime".}
proc bodySetAutoDisableTime*(a2: dBodyID; time: dReal) {.importc: "dBodySetAutoDisableTime".}
proc bodyGetAutoDisableFlag*(a2: dBodyID): cint {.importc: "dBodyGetAutoDisableFlag".}
proc bodySetAutoDisableFlag*(a2: dBodyID; do_auto_disable: cint) {.importc: "dBodySetAutoDisableFlag".}
proc bodySetAutoDisableDefaults*(a2: dBodyID) {.importc: "dBodySetAutoDisableDefaults".}
proc bodyGetWorld*(a2: dBodyID): dWorldID {.importc: "dBodyGetWorld".}
proc bodyCreate*(a2: dWorldID): dBodyID {.importc: "dBodyCreate".}
proc bodyDestroy*(a2: dBodyID) {.importc: "dBodyDestroy".}
proc bodySetData*(a2: dBodyID; data: pointer) {.importc: "dBodySetData".}
proc bodyGetData*(a2: dBodyID): pointer {.importc: "dBodyGetData".}
proc bodySetPosition*(a2: dBodyID; x: dReal; y: dReal; z: dReal) {.importc: "dBodySetPosition".}
proc bodySetRotation*(a2: dBodyID; R: dMatrix3) {.importc: "dBodySetRotation".}
proc bodySetQuaternion*(a2: dBodyID; q: dQuaternion) {.importc: "dBodySetQuaternion".}
proc bodySetLinearVel*(a2: dBodyID; x: dReal; y: dReal; z: dReal) {.importc: "dBodySetLinearVel".}
proc bodySetAngularVel*(a2: dBodyID; x: dReal; y: dReal; z: dReal) {.importc: "dBodySetAngularVel".}
proc bodyGetPosition*(a2: dBodyID): ptr dReal {.importc: "dBodyGetPosition".}
proc bodyCopyPosition*(body: dBodyID; pos: dVector3) {.importc: "dBodyCopyPosition".}
proc bodyGetRotation*(a2: dBodyID): ptr dReal {.importc: "dBodyGetRotation".}
proc bodyCopyRotation*(a2: dBodyID; R: dMatrix3) {.importc: "dBodyCopyRotation".}
proc bodyGetQuaternion*(a2: dBodyID): ptr dReal {.importc: "dBodyGetQuaternion".}
proc bodyCopyQuaternion*(body: dBodyID; quat: dQuaternion) {.importc: "dBodyCopyQuaternion".}
proc bodyGetLinearVel*(a2: dBodyID): ptr dReal {.importc: "dBodyGetLinearVel".}
proc bodyGetAngularVel*(a2: dBodyID): ptr dReal {.importc: "dBodyGetAngularVel".}
proc bodySetMass*(a2: dBodyID; mass: ptr dMass) {.importc: "dBodySetMass".}
proc bodyGetMass*(a2: dBodyID; mass: ptr dMass) {.importc: "dBodyGetMass".}
proc bodyAddForce*(a2: dBodyID; fx: dReal; fy: dReal; fz: dReal) {.importc: "dBodyAddForce".}
proc bodyAddTorque*(a2: dBodyID; fx: dReal; fy: dReal; fz: dReal) {.importc: "dBodyAddTorque".}
proc bodyAddRelForce*(a2: dBodyID; fx: dReal; fy: dReal; fz: dReal) {.importc: "dBodyAddRelForce".}
proc bodyAddRelTorque*(a2: dBodyID; fx: dReal; fy: dReal; fz: dReal) {.importc: "dBodyAddRelTorque".}
proc bodyAddForceAtPos*(a2: dBodyID; fx: dReal; fy: dReal; fz: dReal; px: dReal; py: dReal; pz: dReal) {.importc: "dBodyAddForceAtPos".}
proc bodyAddForceAtRelPos*(a2: dBodyID; fx: dReal; fy: dReal; fz: dReal; px: dReal; py: dReal; pz: dReal) {.importc: "dBodyAddForceAtRelPos".}
proc bodyAddRelForceAtPos*(a2: dBodyID; fx: dReal; fy: dReal; fz: dReal; px: dReal; py: dReal; pz: dReal) {.importc: "dBodyAddRelForceAtPos".}
proc bodyAddRelForceAtRelPos*(a2: dBodyID; fx: dReal; fy: dReal; fz: dReal; px: dReal; py: dReal; pz: dReal) {.importc: "dBodyAddRelForceAtRelPos".}
proc bodyGetForce*(a2: dBodyID): ptr dReal {.importc: "dBodyGetForce".}
proc bodyGetTorque*(a2: dBodyID): ptr dReal {.importc: "dBodyGetTorque".}
proc bodySetForce*(b: dBodyID; x: dReal; y: dReal; z: dReal) {.importc: "dBodySetForce".}
proc bodySetTorque*(b: dBodyID; x: dReal; y: dReal; z: dReal) {.importc: "dBodySetTorque".}
proc bodyGetRelPointPos*(a2: dBodyID; px: dReal; py: dReal; pz: dReal; result: dVector3) {.importc: "dBodyGetRelPointPos".}
proc bodyGetRelPointVel*(a2: dBodyID; px: dReal; py: dReal; pz: dReal; result: dVector3) {.importc: "dBodyGetRelPointVel".}
proc bodyGetPointVel*(a2: dBodyID; px: dReal; py: dReal; pz: dReal; result: dVector3) {.importc: "dBodyGetPointVel".}
proc bodyGetPosRelPoint*(a2: dBodyID; px: dReal; py: dReal; pz: dReal; result: dVector3) {.importc: "dBodyGetPosRelPoint".}
proc bodyVectorToWorld*(a2: dBodyID; px: dReal; py: dReal; pz: dReal; result: dVector3) {.importc: "dBodyVectorToWorld".}
proc bodyVectorFromWorld*(a2: dBodyID; px: dReal; py: dReal; pz: dReal; result: dVector3) {.importc: "dBodyVectorFromWorld".}
proc bodySetFiniteRotationMode*(a2: dBodyID; mode: cint) {.importc: "dBodySetFiniteRotationMode".}
proc bodySetFiniteRotationAxis*(a2: dBodyID; x: dReal; y: dReal; z: dReal) {.importc: "dBodySetFiniteRotationAxis".}
proc bodyGetFiniteRotationMode*(a2: dBodyID): cint {.importc: "dBodyGetFiniteRotationMode".}
proc bodyGetFiniteRotationAxis*(a2: dBodyID; result: dVector3) {.importc: "dBodyGetFiniteRotationAxis".}
proc bodyGetNumJoints*(b: dBodyID): cint {.importc: "dBodyGetNumJoints".}
proc bodyGetJoint*(a2: dBodyID; index: cint): dJointID {.importc: "dBodyGetJoint".}
proc bodySetDynamic*(a2: dBodyID) {.importc: "dBodySetDynamic".}
proc bodySetKinematic*(a2: dBodyID) {.importc: "dBodySetKinematic".}
proc bodyIsKinematic*(a2: dBodyID): cint {.importc: "dBodyIsKinematic".}
proc bodyEnable*(a2: dBodyID) {.importc: "dBodyEnable".}
proc bodyDisable*(a2: dBodyID) {.importc: "dBodyDisable".}
proc bodyIsEnabled*(a2: dBodyID): cint {.importc: "dBodyIsEnabled".}
proc bodySetGravityMode*(b: dBodyID; mode: cint) {.importc: "dBodySetGravityMode".}
proc bodyGetGravityMode*(b: dBodyID): cint {.importc: "dBodyGetGravityMode".}
proc bodySetMovedCallback*(b: dBodyID; callback: proc (a2: dBodyID)) {.importc: "dBodySetMovedCallback".}
proc bodyGetFirstGeom*(b: dBodyID): dGeomID {.importc: "dBodyGetFirstGeom".}
proc bodyGetNextGeom*(g: dGeomID): dGeomID {.importc: "dBodyGetNextGeom".}
proc bodySetDampingDefaults*(b: dBodyID) {.importc: "dBodySetDampingDefaults".}
proc bodyGetLinearDamping*(b: dBodyID): dReal {.importc: "dBodyGetLinearDamping".}
proc bodySetLinearDamping*(b: dBodyID; scale: dReal) {.importc: "dBodySetLinearDamping".}
proc bodyGetAngularDamping*(b: dBodyID): dReal {.importc: "dBodyGetAngularDamping".}
proc bodySetAngularDamping*(b: dBodyID; scale: dReal) {.importc: "dBodySetAngularDamping".}
proc bodySetDamping*(b: dBodyID; linear_scale: dReal; angular_scale: dReal) {.importc: "dBodySetDamping".}
proc bodyGetLinearDampingThreshold*(b: dBodyID): dReal {.importc: "dBodyGetLinearDampingThreshold".}
proc bodySetLinearDampingThreshold*(b: dBodyID; threshold: dReal) {.importc: "dBodySetLinearDampingThreshold".}
proc bodyGetAngularDampingThreshold*(b: dBodyID): dReal {.importc: "dBodyGetAngularDampingThreshold".}
proc bodySetAngularDampingThreshold*(b: dBodyID; threshold: dReal) {.importc: "dBodySetAngularDampingThreshold".}
proc bodyGetMaxAngularSpeed*(b: dBodyID): dReal {.importc: "dBodyGetMaxAngularSpeed".}
proc bodySetMaxAngularSpeed*(b: dBodyID; max_speed: dReal) {.importc: "dBodySetMaxAngularSpeed".}
proc bodyGetGyroscopicMode*(b: dBodyID): cint {.importc: "dBodyGetGyroscopicMode".}
proc bodySetGyroscopicMode*(b: dBodyID; enabled: cint) {.importc: "dBodySetGyroscopicMode".}
proc jointCreateBall*(a2: dWorldID; a3: dJointGroupID): dJointID {.importc: "dJointCreateBall".}
proc jointCreateHinge*(a2: dWorldID; a3: dJointGroupID): dJointID {.importc: "dJointCreateHinge".}
proc jointCreateSlider*(a2: dWorldID; a3: dJointGroupID): dJointID {.importc: "dJointCreateSlider".}
proc jointCreateContact*(a2: dWorldID; a3: dJointGroupID; a4: ptr dContact): dJointID {.importc: "dJointCreateContact".}
proc jointCreateHinge2*(a2: dWorldID; a3: dJointGroupID): dJointID {.importc: "dJointCreateHinge2".}
proc jointCreateUniversal*(a2: dWorldID; a3: dJointGroupID): dJointID {.importc: "dJointCreateUniversal".}
proc jointCreatePR*(a2: dWorldID; a3: dJointGroupID): dJointID {.importc: "dJointCreatePR".}
proc jointCreatePU*(a2: dWorldID; a3: dJointGroupID): dJointID {.importc: "dJointCreatePU".}
proc jointCreatePiston*(a2: dWorldID; a3: dJointGroupID): dJointID {.importc: "dJointCreatePiston".}
proc jointCreateFixed*(a2: dWorldID; a3: dJointGroupID): dJointID {.importc: "dJointCreateFixed".}
proc jointCreateNull*(a2: dWorldID; a3: dJointGroupID): dJointID {.importc: "dJointCreateNull".}
proc jointCreateAMotor*(a2: dWorldID; a3: dJointGroupID): dJointID {.importc: "dJointCreateAMotor".}
proc jointCreateLMotor*(a2: dWorldID; a3: dJointGroupID): dJointID {.importc: "dJointCreateLMotor".}
proc jointCreatePlane2D*(a2: dWorldID; a3: dJointGroupID): dJointID {.importc: "dJointCreatePlane2D".}
proc jointCreateDBall*(a2: dWorldID; a3: dJointGroupID): dJointID {.importc: "dJointCreateDBall".}
proc jointCreateDHinge*(a2: dWorldID; a3: dJointGroupID): dJointID {.importc: "dJointCreateDHinge".}
proc jointCreateTransmission*(a2: dWorldID; a3: dJointGroupID): dJointID {.importc: "dJointCreateTransmission".}
proc jointDestroy*(a2: dJointID) {.importc: "dJointDestroy".}
proc jointGroupCreate*(max_size: cint): dJointGroupID {.importc: "dJointGroupCreate".}
proc jointGroupDestroy*(a2: dJointGroupID) {.importc: "dJointGroupDestroy".}
proc jointGroupEmpty*(a2: dJointGroupID) {.importc: "dJointGroupEmpty".}
proc jointGetNumBodies*(a2: dJointID): cint {.importc: "dJointGetNumBodies".}
proc jointAttach*(a2: dJointID; body1: dBodyID; body2: dBodyID) {.importc: "dJointAttach".}
proc jointEnable*(a2: dJointID) {.importc: "dJointEnable".}
proc jointDisable*(a2: dJointID) {.importc: "dJointDisable".}
proc jointIsEnabled*(a2: dJointID): cint {.importc: "dJointIsEnabled".}
proc jointSetData*(a2: dJointID; data: pointer) {.importc: "dJointSetData".}
proc jointGetData*(a2: dJointID): pointer {.importc: "dJointGetData".}
proc jointGetType*(a2: dJointID): dJointType {.importc: "dJointGetType".}
proc jointGetBody*(a2: dJointID; index: cint): dBodyID {.importc: "dJointGetBody".}
proc jointSetFeedback*(a2: dJointID; a3: ptr dJointFeedback) {.importc: "dJointSetFeedback".}
proc jointGetFeedback*(a2: dJointID): ptr dJointFeedback {.importc: "dJointGetFeedback".}
proc jointSetBallAnchor*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetBallAnchor".}
proc jointSetBallAnchor2*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetBallAnchor2".}
proc jointSetBallParam*(a2: dJointID; parameter: cint; value: dReal) {.importc: "dJointSetBallParam".}
proc jointSetHingeAnchor*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetHingeAnchor".}
proc jointSetHingeAnchorDelta*(a2: dJointID; x: dReal; y: dReal; z: dReal; ax: dReal; ay: dReal; az: dReal) {.importc: "dJointSetHingeAnchorDelta".}
proc jointSetHingeAxis*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetHingeAxis".}
proc jointSetHingeAxisOffset*(j: dJointID; x: dReal; y: dReal; z: dReal; angle: dReal) {.importc: "dJointSetHingeAxisOffset".}
proc jointSetHingeParam*(a2: dJointID; parameter: cint; value: dReal) {.importc: "dJointSetHingeParam".}
proc jointAddHingeTorque*(joint: dJointID; torque: dReal) {.importc: "dJointAddHingeTorque".}
proc jointSetSliderAxis*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetSliderAxis".}
proc jointSetSliderAxisDelta*(a2: dJointID; x: dReal; y: dReal; z: dReal; ax: dReal; ay: dReal; az: dReal) {.importc: "dJointSetSliderAxisDelta".}
proc jointSetSliderParam*(a2: dJointID; parameter: cint; value: dReal) {.importc: "dJointSetSliderParam".}
proc jointAddSliderForce*(joint: dJointID; force: dReal) {.importc: "dJointAddSliderForce".}
proc jointSetHinge2Anchor*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetHinge2Anchor".}
proc jointSetHinge2Axes*(j: dJointID; axis1: ptr dReal; axis2: ptr dReal) {.importc: "dJointSetHinge2Axes".}
proc jointSetHinge2Axis1*(j: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetHinge2Axis1".}
proc jointSetHinge2Axis2*(j: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetHinge2Axis2".}
proc jointSetHinge2Param*(a2: dJointID; parameter: cint; value: dReal) {.importc: "dJointSetHinge2Param".}
proc jointAddHinge2Torques*(joint: dJointID; torque1: dReal; torque2: dReal) {.importc: "dJointAddHinge2Torques".}
proc jointSetUniversalAnchor*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetUniversalAnchor".}
proc jointSetUniversalAxis1*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetUniversalAxis1".}
proc jointSetUniversalAxis1Offset*(a2: dJointID; x: dReal; y: dReal; z: dReal; offset1: dReal; offset2: dReal) {.importc: "dJointSetUniversalAxis1Offset".}
proc jointSetUniversalAxis2*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetUniversalAxis2".}
proc jointSetUniversalAxis2Offset*(a2: dJointID; x: dReal; y: dReal; z: dReal; offset1: dReal; offset2: dReal) {.importc: "dJointSetUniversalAxis2Offset".}
proc jointSetUniversalParam*(a2: dJointID; parameter: cint; value: dReal) {.importc: "dJointSetUniversalParam".}
proc jointAddUniversalTorques*(joint: dJointID; torque1: dReal; torque2: dReal) {.importc: "dJointAddUniversalTorques".}
proc jointSetPRAnchor*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetPRAnchor".}
proc jointSetPRAxis1*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetPRAxis1".}
proc jointSetPRAxis2*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetPRAxis2".}
proc jointSetPRParam*(a2: dJointID; parameter: cint; value: dReal) {.importc: "dJointSetPRParam".}
proc jointAddPRTorque*(j: dJointID; torque: dReal) {.importc: "dJointAddPRTorque".}
proc jointSetPUAnchor*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetPUAnchor".}
proc jointSetPUAnchorDelta*(a2: dJointID; x: dReal; y: dReal; z: dReal; dx: dReal; dy: dReal; dz: dReal) {.importc: "dJointSetPUAnchorDelta".}
proc jointSetPUAnchorOffset*(a2: dJointID; x: dReal; y: dReal; z: dReal; dx: dReal; dy: dReal; dz: dReal) {.importc: "dJointSetPUAnchorOffset".}
proc jointSetPUAxis1*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetPUAxis1".}
proc jointSetPUAxis2*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetPUAxis2".}
proc jointSetPUAxis3*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetPUAxis3".}
proc jointSetPUAxisP*(id: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetPUAxisP".}
proc jointSetPUParam*(a2: dJointID; parameter: cint; value: dReal) {.importc: "dJointSetPUParam".}
proc jointAddPUTorque*(j: dJointID; torque: dReal) {.importc: "dJointAddPUTorque".}
proc jointSetPistonAnchor*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetPistonAnchor".}
proc jointSetPistonAnchorOffset*(j: dJointID; x: dReal; y: dReal; z: dReal; dx: dReal; dy: dReal; dz: dReal) {.importc: "dJointSetPistonAnchorOffset".}
proc jointSetPistonAxis*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetPistonAxis".}
proc jointSetPistonAxisDelta*(j: dJointID; x: dReal; y: dReal; z: dReal; ax: dReal; ay: dReal; az: dReal) {.importc: "dJointSetPistonAxisDelta".}
proc jointSetPistonParam*(a2: dJointID; parameter: cint; value: dReal) {.importc: "dJointSetPistonParam".}
proc jointAddPistonForce*(joint: dJointID; force: dReal) {.importc: "dJointAddPistonForce".}
proc jointSetFixed*(a2: dJointID) {.importc: "dJointSetFixed".}
proc jointSetFixedParam*(a2: dJointID; parameter: cint; value: dReal) {.importc: "dJointSetFixedParam".}
proc jointSetAMotorNumAxes*(a2: dJointID; num: cint) {.importc: "dJointSetAMotorNumAxes".}
proc jointSetAMotorAxis*(a2: dJointID; anum: cint; rel: cint; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetAMotorAxis".}
proc jointSetAMotorAngle*(a2: dJointID; anum: cint; angle: dReal) {.importc: "dJointSetAMotorAngle".}
proc jointSetAMotorParam*(a2: dJointID; parameter: cint; value: dReal) {.importc: "dJointSetAMotorParam".}
proc jointSetAMotorMode*(a2: dJointID; mode: cint) {.importc: "dJointSetAMotorMode".}
proc jointAddAMotorTorques*(a2: dJointID; torque1: dReal; torque2: dReal; torque3: dReal) {.importc: "dJointAddAMotorTorques".}
proc jointSetLMotorNumAxes*(a2: dJointID; num: cint) {.importc: "dJointSetLMotorNumAxes".}
proc jointSetLMotorAxis*(a2: dJointID; anum: cint; rel: cint; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetLMotorAxis".}
proc jointSetLMotorParam*(a2: dJointID; parameter: cint; value: dReal) {.importc: "dJointSetLMotorParam".}
proc jointSetPlane2DXParam*(a2: dJointID; parameter: cint; value: dReal) {.importc: "dJointSetPlane2DXParam".}
proc jointSetPlane2DYParam*(a2: dJointID; parameter: cint; value: dReal) {.importc: "dJointSetPlane2DYParam".}
proc jointSetPlane2DAngleParam*(a2: dJointID; parameter: cint; value: dReal) {.importc: "dJointSetPlane2DAngleParam".}
proc jointGetBallAnchor*(a2: dJointID; result: dVector3) {.importc: "dJointGetBallAnchor".}
proc jointGetBallAnchor2*(a2: dJointID; result: dVector3) {.importc: "dJointGetBallAnchor2".}
proc jointGetBallParam*(a2: dJointID; parameter: cint): dReal {.importc: "dJointGetBallParam".}
proc jointGetHingeAnchor*(a2: dJointID; result: dVector3) {.importc: "dJointGetHingeAnchor".}
proc jointGetHingeAnchor2*(a2: dJointID; result: dVector3) {.importc: "dJointGetHingeAnchor2".}
proc jointGetHingeAxis*(a2: dJointID; result: dVector3) {.importc: "dJointGetHingeAxis".}
proc jointGetHingeParam*(a2: dJointID; parameter: cint): dReal {.importc: "dJointGetHingeParam".}
proc jointGetHingeAngle*(a2: dJointID): dReal {.importc: "dJointGetHingeAngle".}
proc jointGetHingeAngleRate*(a2: dJointID): dReal {.importc: "dJointGetHingeAngleRate".}
proc jointGetSliderPosition*(a2: dJointID): dReal {.importc: "dJointGetSliderPosition".}
proc jointGetSliderPositionRate*(a2: dJointID): dReal {.importc: "dJointGetSliderPositionRate".}
proc jointGetSliderAxis*(a2: dJointID; result: dVector3) {.importc: "dJointGetSliderAxis".}
proc jointGetSliderParam*(a2: dJointID; parameter: cint): dReal {.importc: "dJointGetSliderParam".}
proc jointGetHinge2Anchor*(a2: dJointID; result: dVector3) {.importc: "dJointGetHinge2Anchor".}
proc jointGetHinge2Anchor2*(a2: dJointID; result: dVector3) {.importc: "dJointGetHinge2Anchor2".}
proc jointGetHinge2Axis1*(a2: dJointID; result: dVector3) {.importc: "dJointGetHinge2Axis1".}
proc jointGetHinge2Axis2*(a2: dJointID; result: dVector3) {.importc: "dJointGetHinge2Axis2".}
proc jointGetHinge2Param*(a2: dJointID; parameter: cint): dReal {.importc: "dJointGetHinge2Param".}
proc jointGetHinge2Angle1*(a2: dJointID): dReal {.importc: "dJointGetHinge2Angle1".}
proc jointGetHinge2Angle2*(a2: dJointID): dReal {.importc: "dJointGetHinge2Angle2".}
proc jointGetHinge2Angle1Rate*(a2: dJointID): dReal {.importc: "dJointGetHinge2Angle1Rate".}
proc jointGetHinge2Angle2Rate*(a2: dJointID): dReal {.importc: "dJointGetHinge2Angle2Rate".}
proc jointGetUniversalAnchor*(a2: dJointID; result: dVector3) {.importc: "dJointGetUniversalAnchor".}
proc jointGetUniversalAnchor2*(a2: dJointID; result: dVector3) {.importc: "dJointGetUniversalAnchor2".}
proc jointGetUniversalAxis1*(a2: dJointID; result: dVector3) {.importc: "dJointGetUniversalAxis1".}
proc jointGetUniversalAxis2*(a2: dJointID; result: dVector3) {.importc: "dJointGetUniversalAxis2".}
proc jointGetUniversalParam*(a2: dJointID; parameter: cint): dReal {.importc: "dJointGetUniversalParam".}
proc jointGetUniversalAngles*(a2: dJointID; angle1: ptr dReal; angle2: ptr dReal) {.importc: "dJointGetUniversalAngles".}
proc jointGetUniversalAngle1*(a2: dJointID): dReal {.importc: "dJointGetUniversalAngle1".}
proc jointGetUniversalAngle2*(a2: dJointID): dReal {.importc: "dJointGetUniversalAngle2".}
proc jointGetUniversalAngle1Rate*(a2: dJointID): dReal {.importc: "dJointGetUniversalAngle1Rate".}
proc jointGetUniversalAngle2Rate*(a2: dJointID): dReal {.importc: "dJointGetUniversalAngle2Rate".}
proc jointGetPRAnchor*(a2: dJointID; result: dVector3) {.importc: "dJointGetPRAnchor".}
proc jointGetPRPosition*(a2: dJointID): dReal {.importc: "dJointGetPRPosition".}
proc jointGetPRPositionRate*(a2: dJointID): dReal {.importc: "dJointGetPRPositionRate".}
proc jointGetPRAngle*(a2: dJointID): dReal {.importc: "dJointGetPRAngle".}
proc jointGetPRAngleRate*(a2: dJointID): dReal {.importc: "dJointGetPRAngleRate".}
proc jointGetPRAxis1*(a2: dJointID; result: dVector3) {.importc: "dJointGetPRAxis1".}
proc jointGetPRAxis2*(a2: dJointID; result: dVector3) {.importc: "dJointGetPRAxis2".}
proc jointGetPRParam*(a2: dJointID; parameter: cint): dReal {.importc: "dJointGetPRParam".}
proc jointGetPUAnchor*(a2: dJointID; result: dVector3) {.importc: "dJointGetPUAnchor".}
proc jointGetPUPosition*(a2: dJointID): dReal {.importc: "dJointGetPUPosition".}
proc jointGetPUPositionRate*(a2: dJointID): dReal {.importc: "dJointGetPUPositionRate".}
proc jointGetPUAxis1*(a2: dJointID; result: dVector3) {.importc: "dJointGetPUAxis1".}
proc jointGetPUAxis2*(a2: dJointID; result: dVector3) {.importc: "dJointGetPUAxis2".}
proc jointGetPUAxis3*(a2: dJointID; result: dVector3) {.importc: "dJointGetPUAxis3".}
proc jointGetPUAxisP*(id: dJointID; result: dVector3) {.importc: "dJointGetPUAxisP".}
proc jointGetPUAngles*(a2: dJointID; angle1: ptr dReal; angle2: ptr dReal) {.importc: "dJointGetPUAngles".}
proc jointGetPUAngle1*(a2: dJointID): dReal {.importc: "dJointGetPUAngle1".}
proc jointGetPUAngle1Rate*(a2: dJointID): dReal {.importc: "dJointGetPUAngle1Rate".}
proc jointGetPUAngle2*(a2: dJointID): dReal {.importc: "dJointGetPUAngle2".}
proc jointGetPUAngle2Rate*(a2: dJointID): dReal {.importc: "dJointGetPUAngle2Rate".}
proc jointGetPUParam*(a2: dJointID; parameter: cint): dReal {.importc: "dJointGetPUParam".}
proc jointGetPistonPosition*(a2: dJointID): dReal {.importc: "dJointGetPistonPosition".}
proc jointGetPistonPositionRate*(a2: dJointID): dReal {.importc: "dJointGetPistonPositionRate".}
proc jointGetPistonAngle*(a2: dJointID): dReal {.importc: "dJointGetPistonAngle".}
proc jointGetPistonAngleRate*(a2: dJointID): dReal {.importc: "dJointGetPistonAngleRate".}
proc jointGetPistonAnchor*(a2: dJointID; result: dVector3) {.importc: "dJointGetPistonAnchor".}
proc jointGetPistonAnchor2*(a2: dJointID; result: dVector3) {.importc: "dJointGetPistonAnchor2".}
proc jointGetPistonAxis*(a2: dJointID; result: dVector3) {.importc: "dJointGetPistonAxis".}
proc jointGetPistonParam*(a2: dJointID; parameter: cint): dReal {.importc: "dJointGetPistonParam".}
proc jointGetAMotorNumAxes*(a2: dJointID): cint {.importc: "dJointGetAMotorNumAxes".}
proc jointGetAMotorAxis*(a2: dJointID; anum: cint; result: dVector3) {.importc: "dJointGetAMotorAxis".}
proc jointGetAMotorAxisRel*(a2: dJointID; anum: cint): cint {.importc: "dJointGetAMotorAxisRel".}
proc jointGetAMotorAngle*(a2: dJointID; anum: cint): dReal {.importc: "dJointGetAMotorAngle".}
proc jointGetAMotorAngleRate*(a2: dJointID; anum: cint): dReal {.importc: "dJointGetAMotorAngleRate".}
proc jointGetAMotorParam*(a2: dJointID; parameter: cint): dReal {.importc: "dJointGetAMotorParam".}
proc jointGetAMotorMode*(a2: dJointID): cint {.importc: "dJointGetAMotorMode".}
proc jointGetLMotorNumAxes*(a2: dJointID): cint {.importc: "dJointGetLMotorNumAxes".}
proc jointGetLMotorAxis*(a2: dJointID; anum: cint; result: dVector3) {.importc: "dJointGetLMotorAxis".}
proc jointGetLMotorParam*(a2: dJointID; parameter: cint): dReal {.importc: "dJointGetLMotorParam".}
proc jointGetFixedParam*(a2: dJointID; parameter: cint): dReal {.importc: "dJointGetFixedParam".}
proc jointGetTransmissionContactPoint1*(a2: dJointID; result: dVector3) {.importc: "dJointGetTransmissionContactPoint1".}
proc jointGetTransmissionContactPoint2*(a2: dJointID; result: dVector3) {.importc: "dJointGetTransmissionContactPoint2".}
proc jointSetTransmissionAxis1*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetTransmissionAxis1".}
proc jointGetTransmissionAxis1*(a2: dJointID; result: dVector3) {.importc: "dJointGetTransmissionAxis1".}
proc jointSetTransmissionAxis2*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetTransmissionAxis2".}
proc jointGetTransmissionAxis2*(a2: dJointID; result: dVector3) {.importc: "dJointGetTransmissionAxis2".}
proc jointSetTransmissionAnchor1*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetTransmissionAnchor1".}
proc jointGetTransmissionAnchor1*(a2: dJointID; result: dVector3) {.importc: "dJointGetTransmissionAnchor1".}
proc jointSetTransmissionAnchor2*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetTransmissionAnchor2".}
proc jointGetTransmissionAnchor2*(a2: dJointID; result: dVector3) {.importc: "dJointGetTransmissionAnchor2".}
proc jointSetTransmissionParam*(a2: dJointID; parameter: cint; value: dReal) {.importc: "dJointSetTransmissionParam".}
proc jointGetTransmissionParam*(a2: dJointID; parameter: cint): dReal {.importc: "dJointGetTransmissionParam".}
proc jointSetTransmissionMode*(j: dJointID; mode: cint) {.importc: "dJointSetTransmissionMode".}
proc jointGetTransmissionMode*(j: dJointID): cint {.importc: "dJointGetTransmissionMode".}
proc jointSetTransmissionRatio*(j: dJointID; ratio: dReal) {.importc: "dJointSetTransmissionRatio".}
proc jointGetTransmissionRatio*(j: dJointID): dReal {.importc: "dJointGetTransmissionRatio".}
proc jointSetTransmissionAxis*(j: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetTransmissionAxis".}
proc jointGetTransmissionAxis*(j: dJointID; result: dVector3) {.importc: "dJointGetTransmissionAxis".}
proc jointGetTransmissionAngle1*(j: dJointID): dReal {.importc: "dJointGetTransmissionAngle1".}
proc jointGetTransmissionAngle2*(j: dJointID): dReal {.importc: "dJointGetTransmissionAngle2".}
proc jointGetTransmissionRadius1*(j: dJointID): dReal {.importc: "dJointGetTransmissionRadius1".}
proc jointGetTransmissionRadius2*(j: dJointID): dReal {.importc: "dJointGetTransmissionRadius2".}
proc jointSetTransmissionRadius1*(j: dJointID; radius: dReal) {.importc: "dJointSetTransmissionRadius1".}
proc jointSetTransmissionRadius2*(j: dJointID; radius: dReal) {.importc: "dJointSetTransmissionRadius2".}
proc jointGetTransmissionBacklash*(j: dJointID): dReal {.importc: "dJointGetTransmissionBacklash".}
proc jointSetTransmissionBacklash*(j: dJointID; backlash: dReal) {.importc: "dJointSetTransmissionBacklash".}
proc jointSetDBallAnchor1*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetDBallAnchor1".}
proc jointSetDBallAnchor2*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetDBallAnchor2".}
proc jointGetDBallAnchor1*(a2: dJointID; result: dVector3) {.importc: "dJointGetDBallAnchor1".}
proc jointGetDBallAnchor2*(a2: dJointID; result: dVector3) {.importc: "dJointGetDBallAnchor2".}
proc jointGetDBallDistance*(a2: dJointID): dReal {.importc: "dJointGetDBallDistance".}
proc jointSetDBallDistance*(a2: dJointID; dist: dReal) {.importc: "dJointSetDBallDistance".}
proc jointSetDBallParam*(a2: dJointID; parameter: cint; value: dReal) {.importc: "dJointSetDBallParam".}
proc jointGetDBallParam*(a2: dJointID; parameter: cint): dReal {.importc: "dJointGetDBallParam".}
proc jointSetDHingeAxis*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetDHingeAxis".}
proc jointGetDHingeAxis*(a2: dJointID; result: dVector3) {.importc: "dJointGetDHingeAxis".}
proc jointSetDHingeAnchor1*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetDHingeAnchor1".}
proc jointSetDHingeAnchor2*(a2: dJointID; x: dReal; y: dReal; z: dReal) {.importc: "dJointSetDHingeAnchor2".}
proc jointGetDHingeAnchor1*(a2: dJointID; result: dVector3) {.importc: "dJointGetDHingeAnchor1".}
proc jointGetDHingeAnchor2*(a2: dJointID; result: dVector3) {.importc: "dJointGetDHingeAnchor2".}
proc jointGetDHingeDistance*(a2: dJointID): dReal {.importc: "dJointGetDHingeDistance".}
proc jointSetDHingeParam*(a2: dJointID; parameter: cint; value: dReal) {.importc: "dJointSetDHingeParam".}
proc jointGetDHingeParam*(a2: dJointID; parameter: cint): dReal {.importc: "dJointGetDHingeParam".}
proc connectingJoint*(a2: dBodyID; a3: dBodyID): dJointID {.importc: "dConnectingJoint".}
proc connectingJointList*(a2: dBodyID; a3: dBodyID; a4: ptr dJointID): cint {.importc: "dConnectingJointList".}
proc areConnected*(a2: dBodyID; a3: dBodyID): cint {.importc: "dAreConnected".}
proc areConnectedExcluding*(body1: dBodyID; body2: dBodyID; joint_type: cint): cint {.importc: "dAreConnectedExcluding".}

proc simpleSpaceCreate*(space: dSpaceID): dSpaceID {.importc: "dSimpleSpaceCreate".}
proc hashSpaceCreate*(space: dSpaceID): dSpaceID {.importc: "dHashSpaceCreate".}
proc quadTreeSpaceCreate*(space: dSpaceID; Center: dVector3; Extents: dVector3; Depth: cint): dSpaceID {.importc: "dQuadTreeSpaceCreate".}
proc sweepAndPruneSpaceCreate*(space: dSpaceID; axisorder: cint): dSpaceID {. importc: "dSweepAndPruneSpaceCreate".}
proc spaceDestroy*(a2: dSpaceID) {.importc: "dSpaceDestroy".}
proc hashSpaceSetLevels*(space: dSpaceID; minlevel: cint; maxlevel: cint) {. importc: "dHashSpaceSetLevels".}
proc hashSpaceGetLevels*(space: dSpaceID; minlevel: ptr cint; maxlevel: ptr cint) {. importc: "dHashSpaceGetLevels".}
proc spaceSetCleanup*(space: dSpaceID; mode: cint) {.importc: "dSpaceSetCleanup".}
proc spaceGetCleanup*(space: dSpaceID): cint {.importc: "dSpaceGetCleanup".}
proc spaceSetSublevel*(space: dSpaceID; sublevel: cint) {. importc: "dSpaceSetSublevel".}
proc spaceGetSublevel*(space: dSpaceID): cint {.importc: "dSpaceGetSublevel".}
proc spaceSetManualCleanup*(space: dSpaceID; mode: cint) {. importc: "dSpaceSetManualCleanup".}
proc spaceGetManualCleanup*(space: dSpaceID): cint {. importc: "dSpaceGetManualCleanup".}
proc spaceAdd*(a2: dSpaceID; a3: dGeomID) {.importc: "dSpaceAdd".}
proc spaceRemove*(a2: dSpaceID; a3: dGeomID) {.importc: "dSpaceRemove".}
proc spaceQuery*(a2: dSpaceID; a3: dGeomID): cint {.importc: "dSpaceQuery".}
proc spaceClean*(a2: dSpaceID) {.importc: "dSpaceClean".}
proc spaceGetNumGeoms*(a2: dSpaceID): cint {.importc: "dSpaceGetNumGeoms".}
proc spaceGetGeom*(a2: dSpaceID; i: cint): dGeomID {.importc: "dSpaceGetGeom".}
proc spaceGetClass*(space: dSpaceID): cint {.importc: "dSpaceGetClass".}

proc geomDestroy*(geom: dGeomID) {.importc: "dGeomDestroy".}
proc geomSetData*(geom: dGeomID; data: pointer) {.importc: "dGeomSetData".}
proc geomGetData*(geom: dGeomID): pointer {.importc: "dGeomGetData".}
proc geomSetBody*(geom: dGeomID; body: dBodyID) {.importc: "dGeomSetBody".}
proc geomGetBody*(geom: dGeomID): dBodyID {.importc: "dGeomGetBody".}
proc geomSetPosition*(geom: dGeomID; x: dReal; y: dReal; z: dReal) {.importc: "dGeomSetPosition".}
proc geomSetRotation*(geom: dGeomID; R: dMatrix3) {.importc: "dGeomSetRotation".}
proc geomSetQuaternion*(geom: dGeomID; Q: dQuaternion) {.importc: "dGeomSetQuaternion".}
proc geomGetPosition*(geom: dGeomID): ptr dReal {.importc: "dGeomGetPosition".}
proc geomCopyPosition*(geom: dGeomID; pos: dVector3) {.importc: "dGeomCopyPosition".}
proc geomGetRotation*(geom: dGeomID): ptr dReal {.importc: "dGeomGetRotation".}
proc geomCopyRotation*(geom: dGeomID; R: dMatrix3) {.importc: "dGeomCopyRotation".}
proc geomGetQuaternion*(geom: dGeomID; result: dQuaternion) {.importc: "dGeomGetQuaternion".}
proc geomGetAABB*(geom: dGeomID; aabb: array[6, dReal]) {.importc: "dGeomGetAABB".}
proc geomIsSpace*(geom: dGeomID): cint {.importc: "dGeomIsSpace".}
proc geomGetSpace*(a2: dGeomID): dSpaceID {.importc: "dGeomGetSpace".}
proc geomGetClass*(geom: dGeomID): cint {.importc: "dGeomGetClass".}
proc geomSetCategoryBits*(geom: dGeomID; bits: culong) {.importc: "dGeomSetCategoryBits".}
proc geomSetCollideBits*(geom: dGeomID; bits: culong) {.importc: "dGeomSetCollideBits".}
proc geomGetCategoryBits*(a2: dGeomID): culong {.importc: "dGeomGetCategoryBits".}
proc geomGetCollideBits*(a2: dGeomID): culong {.importc: "dGeomGetCollideBits".}
proc geomEnable*(geom: dGeomID) {.importc: "dGeomEnable".}
proc geomDisable*(geom: dGeomID) {.importc: "dGeomDisable".}
proc geomIsEnabled*(geom: dGeomID): cint {.importc: "dGeomIsEnabled".}
proc geomLowLevelControl*(geom: dGeomID; controlClass: cint; controlCode: cint; dataValue: pointer; dataSize: ptr cint): cint {.importc: "dGeomLowLevelControl".}
proc geomGetRelPointPos*(geom: dGeomID; px: dReal; py: dReal; pz: dReal; result: dVector3) {.importc: "dGeomGetRelPointPos".}
proc geomGetPosRelPoint*(geom: dGeomID; px: dReal; py: dReal; pz: dReal; result: dVector3) {.importc: "dGeomGetPosRelPoint".}
proc geomVectorToWorld*(geom: dGeomID; px: dReal; py: dReal; pz: dReal; result: dVector3) {.importc: "dGeomVectorToWorld".}
proc geomVectorFromWorld*(geom: dGeomID; px: dReal; py: dReal; pz: dReal; result: dVector3) {.importc: "dGeomVectorFromWorld".}
proc geomSetOffsetPosition*(geom: dGeomID; x: dReal; y: dReal; z: dReal) {.importc: "dGeomSetOffsetPosition".}
proc geomSetOffsetRotation*(geom: dGeomID; R: dMatrix3) {.importc: "dGeomSetOffsetRotation".}
proc geomSetOffsetQuaternion*(geom: dGeomID; Q: dQuaternion) {.importc: "dGeomSetOffsetQuaternion".}
proc geomSetOffsetWorldPosition*(geom: dGeomID; x: dReal; y: dReal; z: dReal) {.importc: "dGeomSetOffsetWorldPosition".}
proc geomSetOffsetWorldRotation*(geom: dGeomID; R: dMatrix3) {.importc: "dGeomSetOffsetWorldRotation".}
proc geomSetOffsetWorldQuaternion*(geom: dGeomID; a3: dQuaternion) {.importc: "dGeomSetOffsetWorldQuaternion".}
proc geomClearOffset*(geom: dGeomID) {.importc: "dGeomClearOffset".}
proc geomIsOffset*(geom: dGeomID): cint {.importc: "dGeomIsOffset".}
proc geomGetOffsetPosition*(geom: dGeomID): ptr dReal {.importc: "dGeomGetOffsetPosition".}
proc geomCopyOffsetPosition*(geom: dGeomID; pos: dVector3) {.importc: "dGeomCopyOffsetPosition".}
proc geomGetOffsetRotation*(geom: dGeomID): ptr dReal {.importc: "dGeomGetOffsetRotation".}
proc geomCopyOffsetRotation*(geom: dGeomID; R: dMatrix3) {.importc: "dGeomCopyOffsetRotation".}
proc geomGetOffsetQuaternion*(geom: dGeomID; result: dQuaternion) {.importc: "dGeomGetOffsetQuaternion".}
proc collide*(o1: dGeomID; o2: dGeomID; flags: cint; contact: ptr dContactGeom; skip: cint): cint {.importc: "dCollide".}
proc spaceCollide*(space: dSpaceID; data: pointer; callback: ptr dNearCallback) {.importc: "dSpaceCollide".}
proc spaceCollide2*(space1: dGeomID; space2: dGeomID; data: pointer; callback: ptr dNearCallback) {.importc: "dSpaceCollide2".}
proc createSphere*(space: dSpaceID; radius: dReal): dGeomID {.importc: "dCreateSphere".}
proc geomSphereSetRadius*(sphere: dGeomID; radius: dReal) {.importc: "dGeomSphereSetRadius".}
proc geomSphereGetRadius*(sphere: dGeomID): dReal {.importc: "dGeomSphereGetRadius".}
proc geomSpherePointDepth*(sphere: dGeomID; x: dReal; y: dReal; z: dReal): dReal {.importc: "dGeomSpherePointDepth".}
proc createConvex*(space: dSpaceID; planes: ptr dReal; planecount: cuint; points: ptr dReal; pointcount: cuint; polygons: ptr cuint): dGeomID {.importc: "dCreateConvex".}
proc geomSetConvex*(g: dGeomID; planes: ptr dReal; count: cuint; points: ptr dReal; pointcount: cuint; polygons: ptr cuint) {.importc: "dGeomSetConvex".}
proc createBox*(space: dSpaceID; lx: dReal; ly: dReal; lz: dReal): dGeomID {.importc: "dCreateBox".}
proc geomBoxSetLengths*(box: dGeomID; lx: dReal; ly: dReal; lz: dReal) {.importc: "dGeomBoxSetLengths".}
proc geomBoxGetLengths*(box: dGeomID; result: dVector3) {.importc: "dGeomBoxGetLengths".}
proc geomBoxPointDepth*(box: dGeomID; x: dReal; y: dReal; z: dReal): dReal {.importc: "dGeomBoxPointDepth".}
proc createPlane*(space: dSpaceID; a: dReal; b: dReal; c: dReal; d: dReal): dGeomID {.importc: "dCreatePlane".}
proc geomPlaneSetParams*(plane: dGeomID; a: dReal; b: dReal; c: dReal; d: dReal) {.importc: "dGeomPlaneSetParams".}
proc geomPlaneGetParams*(plane: dGeomID; result: dVector4) {.importc: "dGeomPlaneGetParams".}
proc geomPlanePointDepth*(plane: dGeomID; x: dReal; y: dReal; z: dReal): dReal {.importc: "dGeomPlanePointDepth".}
proc createCapsule*(space: dSpaceID; radius: dReal; length: dReal): dGeomID {.importc: "dCreateCapsule".}
proc geomCapsuleSetParams*(ccylinder: dGeomID; radius: dReal; length: dReal) {.importc: "dGeomCapsuleSetParams".}
proc geomCapsuleGetParams*(ccylinder: dGeomID; radius: ptr dReal; length: ptr dReal) {.importc: "dGeomCapsuleGetParams".}
proc geomCapsulePointDepth*(ccylinder: dGeomID; x: dReal; y: dReal; z: dReal): dReal {.importc: "dGeomCapsulePointDepth".}
proc createCylinder*(space: dSpaceID; radius: dReal; length: dReal): dGeomID {.importc: "dCreateCylinder".}
proc geomCylinderSetParams*(cylinder: dGeomID; radius: dReal; length: dReal) {.importc: "dGeomCylinderSetParams".}
proc geomCylinderGetParams*(cylinder: dGeomID; radius: ptr dReal; length: ptr dReal) {.importc: "dGeomCylinderGetParams".}
proc createRay*(space: dSpaceID; length: dReal): dGeomID {.importc: "dCreateRay".}
proc geomRaySetLength*(ray: dGeomID; length: dReal) {.importc: "dGeomRaySetLength".}
proc geomRayGetLength*(ray: dGeomID): dReal {.importc: "dGeomRayGetLength".}
proc geomRaySet*(ray: dGeomID; px: dReal; py: dReal; pz: dReal; dx: dReal; dy: dReal; dz: dReal) {.importc: "dGeomRaySet".}
proc geomRayGet*(ray: dGeomID; start: dVector3; dir: dVector3) {.importc: "dGeomRayGet".}
proc geomRaySetParams*(g: dGeomID; FirstContact: cint; BackfaceCull: cint) {.importc: "dGeomRaySetParams".}
proc geomRayGetParams*(g: dGeomID; FirstContact: ptr cint; BackfaceCull: ptr cint) {.importc: "dGeomRayGetParams".}
proc geomRaySetFirstContact*(g: dGeomID; firstContact: cint) {.importc: "dGeomRaySetFirstContact".}
proc geomRayGetFirstContact*(g: dGeomID): cint {.importc: "dGeomRayGetFirstContact".}
proc geomRaySetBackfaceCull*(g: dGeomID; backfaceCull: cint) {.importc: "dGeomRaySetBackfaceCull".}
proc geomRayGetBackfaceCull*(g: dGeomID): cint {.importc: "dGeomRayGetBackfaceCull".}
proc geomRaySetClosestHit*(g: dGeomID; closestHit: cint) {.importc: "dGeomRaySetClosestHit".}
proc geomRayGetClosestHit*(g: dGeomID): cint {.importc: "dGeomRayGetClosestHit".}
proc createGeomTransform*(space: dSpaceID): dGeomID {.importc: "dCreateGeomTransform".}
proc geomTransformSetGeom*(g: dGeomID; obj: dGeomID) {.importc: "dGeomTransformSetGeom".}
proc geomTransformGetGeom*(g: dGeomID): dGeomID {.importc: "dGeomTransformGetGeom".}
proc geomTransformSetCleanup*(g: dGeomID; mode: cint) {.importc: "dGeomTransformSetCleanup".}
proc geomTransformGetCleanup*(g: dGeomID): cint {.importc: "dGeomTransformGetCleanup".}
proc geomTransformSetInfo*(g: dGeomID; mode: cint) {.importc: "dGeomTransformSetInfo".}
proc geomTransformGetInfo*(g: dGeomID): cint {.importc: "dGeomTransformGetInfo".}
proc createHeightfield*(space: dSpaceID; data: dHeightfieldDataID; bPlaceable: cint): dGeomID {.importc: "dCreateHeightfield".}
proc geomHeightfieldDataCreate*(): dHeightfieldDataID {.importc: "dGeomHeightfieldDataCreate".}
proc geomHeightfieldDataDestroy*(d: dHeightfieldDataID) {.importc: "dGeomHeightfieldDataDestroy".}
proc geomHeightfieldDataBuildCallback*(d: dHeightfieldDataID; pUserData: pointer; pCallback: ptr dHeightfieldGetHeight; width: dReal; depth: dReal; widthSamples: cint; depthSamples: cint; scale: dReal; offset: dReal; thickness: dReal; bWrap: cint) {.importc: "dGeomHeightfieldDataBuildCallback".}
proc geomHeightfieldDataBuildByte*(d: dHeightfieldDataID; pHeightData: ptr cuchar; bCopyHeightData: cint; width: dReal; depth: dReal; widthSamples: cint; depthSamples: cint; scale: dReal; offset: dReal; thickness: dReal; bWrap: cint) {.importc: "dGeomHeightfieldDataBuildByte".}
proc geomHeightfieldDataBuildShort*(d: dHeightfieldDataID; pHeightData: ptr cshort; bCopyHeightData: cint;  width: dReal; depth: dReal; widthSamples: cint;  depthSamples: cint; scale: dReal; offset: dReal;  thickness: dReal; bWrap: cint) {.importc: "dGeomHeightfieldDataBuildShort".}
proc geomHeightfieldDataBuildSingle*(d: dHeightfieldDataID; pHeightData: ptr cfloat; bCopyHeightData: cint; width: dReal; depth: dReal; widthSamples: cint; depthSamples: cint; scale: dReal; offset: dReal; thickness: dReal; bWrap: cint) {.importc: "dGeomHeightfieldDataBuildSingle".}
proc geomHeightfieldDataBuildDouble*(d: dHeightfieldDataID; pHeightData: ptr cdouble; bCopyHeightData: cint; width: dReal; depth: dReal; widthSamples: cint; depthSamples: cint; scale: dReal; offset: dReal; thickness: dReal; bWrap: cint) {.importc: "dGeomHeightfieldDataBuildDouble".}
proc geomHeightfieldDataSetBounds*(d: dHeightfieldDataID; minHeight: dReal; maxHeight: dReal) {.importc: "dGeomHeightfieldDataSetBounds".}
proc geomHeightfieldSetHeightfieldData*(g: dGeomID; d: dHeightfieldDataID) {.importc: "dGeomHeightfieldSetHeightfieldData".}
proc geomHeightfieldGetHeightfieldData*(g: dGeomID): dHeightfieldDataID {.importc: "dGeomHeightfieldGetHeightfieldData".}
proc closestLineSegmentPoints*(a1: dVector3; a2: dVector3; b1: dVector3; b2: dVector3; cp1: dVector3; cp2: dVector3) {.importc: "dClosestLineSegmentPoints".}
proc boxTouchesBox*(p1: dVector3; R1: dMatrix3; side1: dVector3; p2: dVector3;  R2: dMatrix3; side2: dVector3): cint {.importc: "dBoxTouchesBox".}
proc boxBox*(p1: dVector3; R1: dMatrix3; side1: dVector3; p2: dVector3; R2: dMatrix3; side2: dVector3; normal: dVector3; depth: ptr dReal; return_code: ptr cint; flags: cint; contact: ptr dContactGeom; skip: cint): cint {.importc: "dBoxBox".}
proc infiniteAABB*(geom: dGeomID; aabb: array[6, dReal]) {.importc: "dInfiniteAABB".}
proc createGeomClass*(classptr: ptr dGeomClass): cint {.importc: "dCreateGeomClass".}
proc geomGetClassData*(a2: dGeomID): pointer {.importc: "dGeomGetClassData".}
proc createGeom*(classnum: cint): dGeomID {.importc: "dCreateGeom".}
proc setColliderOverride*(i: cint; j: cint; fn: ptr dColliderFn) {.importc: "dSetColliderOverride".}

proc threadingAllocateSelfThreadedImplementation*(): dThreadingImplementationID {.importc: "dThreadingAllocateSelfThreadedImplementation".}
proc threadingAllocateMultiThreadedImplementation*(): dThreadingImplementationID {.importc: "dThreadingAllocateMultiThreadedImplementation".}
proc threadingImplementationGetFunctions*(impl: dThreadingImplementationID): ptr dThreadingFunctionsInfo {.importc: "dThreadingImplementationGetFunctions".}
proc threadingImplementationShutdownProcessing*(impl: dThreadingImplementationID) {.importc: "dThreadingImplementationShutdownProcessing".}
proc threadingImplementationCleanupForRestart*(impl: dThreadingImplementationID) {.importc: "dThreadingImplementationCleanupForRestart".}
proc threadingFreeImplementation*(impl: dThreadingImplementationID) {.importc: "dThreadingFreeImplementation".}
proc externalThreadingServeMultiThreadedImplementation*(impl: dThreadingImplementationID; readiness_callback: ptr dThreadReadyToServeCallback; callback_context: pointer) {.importc: "dExternalThreadingServeMultiThreadedImplementation".}
proc threadingAllocateThreadPool*(thread_count: cuint; stack_size: csize; ode_data_allocate_flags: cuint; reserved: pointer): dThreadingThreadPoolID {.importc: "dThreadingAllocateThreadPool".}
proc threadingThreadPoolServeMultiThreadedImplementation*(pool: dThreadingThreadPoolID; impl: dThreadingImplementationID) {.importc: "dThreadingThreadPoolServeMultiThreadedImplementation".}
proc threadingThreadPoolWaitIdleState*(pool: dThreadingThreadPoolID) {.importc: "dThreadingThreadPoolWaitIdleState".}
proc threadingFreeThreadPool*(pool: dThreadingThreadPoolID) {.importc: "dThreadingFreeThreadPool".}
{.pop.}


const
  dCreateCCylinder* = createCapsule
  dGeomCCylinderSetParams* = geomCapsuleSetParams
  dGeomCCylinderGetParams* = geomCapsuleGetParams
  dGeomCCylinderPointDepth* = geomCapsulePointDepth
  dCCylinderClass* = dCapsuleClass
