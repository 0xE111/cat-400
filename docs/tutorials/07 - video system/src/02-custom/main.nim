import tables

import c4/core
import c4/systems

import systems/video


when isMainModule:
  core.run(
    clientSystems={
      "video": CustomVideoSystem.new().as(ref System),
    }.toOrderedTable(),
  )
