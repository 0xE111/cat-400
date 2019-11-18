import tables

import c4/services

import src/systems/physics
import src/systems/input
import src/systems/video

import src/scenarios/init


when isMainModule:
  InputSystem.spawn("input")
  PhysicsSystem.spawn("physics")
  VideoSystem.spawn("video")
  services.joinAll()
