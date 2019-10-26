import ../../../lib/ogre/ogre
import ../../../systems/video/ogre as video
import ../../../utils/stringify


type
  ActionVideoSystem* = object of VideoSystem
    playerNode*: ptr SceneNode


strMethod(ActionVideoSystem, fields=false)
