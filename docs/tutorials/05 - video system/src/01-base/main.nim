import tables

import c4/core
import c4/systems
import c4/systems/video/ogre

when isMainModule:
  core.run(
    clientSystems={
      "video": VideoSystem.new().as(ref System),
    }.toOrderedTable(),
  )
