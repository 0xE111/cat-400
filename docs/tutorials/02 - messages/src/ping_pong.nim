# ping_pong.nim
import tables

import c4/core
import c4/systems

import systems/pinger
import systems/ponger


when isMainModule:
  core.run(
    serverSystems={
      "pinger": PingerSystem.new().as(ref System),
      "ponger": PongerSystem.new().as(ref System),
    }.toOrderedTable(),
  )
