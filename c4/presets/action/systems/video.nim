import tables
import strformat
import logging
import typetraits

import ../../../lib/horde3d/horde3d
import ../../../lib/horde3d/horde3d/helpers

import ../../../core/entities
import ../../../systems
import ../../../systems/video/horde3d as video
import ../../../utils/stringify

import physics
import ../messages


type
  ActionVideoSystem* = object of VideoSystem
    playerNode*: horde3d.Node


strMethod(ActionVideoSystem, fields=false)
