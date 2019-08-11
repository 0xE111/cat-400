# main.nim
import tables

import c4/core
import c4/systems

import systems/fps


when isMainModule:
  core.run(
    serverSystems={"fps": FpsSystem.new().as(ref System)}.toOrderedTable(),
  )
