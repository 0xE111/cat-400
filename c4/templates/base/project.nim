import tables

import c4/core
import c4/services

import src/systems/physics
import src/systems/input
import src/systems/video
import src/systems/network

import src/scenarios/init


when isMainModule:
  InputSystem.spawn("input")
  services.joinAll()
