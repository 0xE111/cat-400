import c4/systems/video/ogre

import ../messages


type VideoSystem* = object of ogre.VideoSystem

proc run*(self: var VideoSystem) =
  ogre.VideoSystem(self).run()

# redefine video system methods below
