import logging
import tables
import strformat

import c4/lib/ode/ode

import c4/systems/physics/ode as ode_physics
import c4/presets/action/messages
import c4/presets/action/systems/physics
import c4/systems
import c4/entities
import c4/utils/stringify

import ../messages as custom_messages


type
  SandboxPhysicsSystem* = object of ActionPhysicsSystem
    cubes: seq[Entity]

  SandboxPhysics* = object of ActionPhysics

strMethod(SandboxPhysicsSystem, fields=false)


method init*(self: ref SandboxPhysicsSystem) =
  # Disable gravitation for now
  procCall self.as(ref ActionPhysicsSystem).init()
  self.world.worldSetGravity(0, 0, 0)

method newPhysics*(self: ref SandboxPhysicsSystem): ref Physics =
  SandboxPhysics.new()

method init*(self: ref SandboxPhysicsSystem, physics: ref SandboxPhysics) =
  procCall self.as(ref ActionPhysicsSystem).init(physics)

  let geometry = createBox(self.space, 1, 1, 1)
  geometry.geomSetBody(physics.body)

  let mass = cast[ptr dMass](alloc(sizeof(dMass)))
  mass.massSetBoxTotal(1.0, 1.0, 1.0, 1.0)
  physics.body.bodySetMass(mass)

  # TODO: send geometry (AABB) to graphics system - AddGeometryMessage


method process*(self: ref SandboxPhysicsSystem, message: ref SystemReadyMessage) =
  # We want to reset our scene when physics system is ready.
  new(ResetSceneMessage).send(self)


method process*(self: ref SandboxPhysicsSystem, message: ref ResetSceneMessage) =
  logging.debug "Resetting scene"

  # first, delete all existing cubes
  for cube in self.cubes:
    (ref DeleteEntityMessage)(entity: cube).send("network")
    cube.delete()

  self.cubes = @[]

  # define cubes locations
  let cubeCoords = @[
    (0.0, 0.0, -100.0),
    (-100.0, 0.0, 0.0),
    (0.0, 0.0, 100.0),
    (100.0, 0.0, 0.0),
    (0.0, 100.0, 0.0),
    (0.0, -100.0, 0.0),
  ]

  var cube: Entity

  for coords in cubeCoords:
    # create cube at each position and send its coordinates
    cube = newEntity()
    (ref CreateEntityMessage)(entity: cube).send("network")

    let physics = self.newPhysics()
    self.init(physics)
    cube[ref Physics] = physics

    logging.debug &"Setting position: {coords[0]} {coords[1]} {coords[2]}"
    cube[ref Physics].body.bodySetPosition(coords[0], coords[1], coords[2])
    # cube[ref Physics].body.bodySetRotation(!!!)
    (ref SyncPositionMessage)(entity: cube, x: coords[0], y: coords[1], z: coords[2]).send("network")

    var mass = ode.dMass()
    mass.addr.massSetBoxTotal(10.0, 1.0, 1.0, 1.0)
    cube[ref Physics].body.bodySetMass(mass.addr)

    self.cubes.add(cube)

  #   cube[ref Physics] = physics
  #   var position = physics.body.bodyGetPosition()
  #   (ref MoveMessage)(
  #     entity: cube,
  #     x: position[][0],
  #     y: position[][1],
  #     z: position[][2],
  #   ).send("network")

  #   # TODO: add RotateMessage

  logging.debug "Scene loaded"
