import c4/systems/video/ogre
import c4/utils/stringify

import ../messages


type
  VideoSystem* = object of ogre.VideoSystem


strMethod(VideoSystem, fields=false)

# redefine video system methods below
