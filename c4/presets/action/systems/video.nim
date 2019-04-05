import tables
import strformat
import logging

import ../../../core/entities
import ../../../systems
import ../../../systems/video/ogre as video
import ../../../utils/stringify

import physics
import ../messages


type
  ActionVideoSystem* = object of VideoSystem
    # playerNode*


strMethod(ActionVideoSystem, fields=false)
