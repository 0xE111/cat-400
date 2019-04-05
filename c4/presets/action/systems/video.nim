import tables
import strformat
import logging

import ../../../core/entities
import ../../../systems
import ../../../lib/ogre/ogre
import ../../../systems/video/ogre as video
import ../../../utils/stringify

import physics
import ../messages


type
  ActionVideoSystem* = object of VideoSystem
    playerNode*: ptr SceneNode


strMethod(ActionVideoSystem, fields=false)

