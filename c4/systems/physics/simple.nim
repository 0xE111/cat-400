import tables
import logging
import strformat
import os
when isMainModule:
  import unittest

import ../../entities
import ../../messages
import ../../loop
import ../../threads


type
  SimplePhysicsSystem* {.inheritable.} = object

  Vector* = tuple[x: float, y: float]

  Physics* {.inheritable.} = object
    position: Vector
    width*, height*: int
    speed: Vector  # defines direction & speed


proc `+`*(v1: Vector, v2: Vector): Vector =
  result.x = v1.x + v2.x
  result.y = v1.y + v2.y


proc init*(self: var SimplePhysicsSystem) =
  discard

proc handleCollision*(entity1: Entity, entity2: Entity, jointPoint: Vector) =
  discard

proc update*(self: var SimplePhysicsSystem, dt: float) =
  # calculate new position for every Physics instance
  for physics in getComponents(Physics).mvalues():
    physics.position = physics.position + physics.speed

  # find collisions
  discard

proc dispose*(self: var SimplePhysicsSystem) =
  discard

method process*(self: var SimplePhysicsSystem, message: ref Message) =
  logging.warn &"Don't know how to process {message}"

proc run*(self: var SimplePhysicsSystem) =
  loop(frequency=30) do:
    self.update(dt)
    while true:
      let message = tryRecv()
      if message.isNil:
        break
      self.process(message)
  do:
    discard


when isMainModule:
  suite "System tests":
    test "Running inside thread":
      spawn("thread") do:
        var system = SimplePhysicsSystem()
        system.init()
        system.run()
        system.dispose()

      sleep 1000
