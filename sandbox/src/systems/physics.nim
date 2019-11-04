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
    boxes: seq[Entity]
    plane: Entity

  BoxPhysics* = object of ActionPhysics
  PlanePhysics* = object of ActionPhysics

strMethod(SandboxPhysicsSystem, fields=false)


method init*(self: ref SandboxPhysicsSystem) =
  # Disable gravitation for now
  procCall self.as(ref ActionPhysicsSystem).init()
  self.world.worldSetGravity(0, 0, 0)


method init*(self: ref SandboxPhysicsSystem, physics: ref BoxPhysics) =
  procCall self.as(ref ActionPhysicsSystem).init(physics)

  let geometry = createBox(self.space, 1, 1, 1)
  geometry.geomSetBody(physics.body)

  let mass = cast[ptr dMass](alloc(sizeof(dMass)))
  # TODO: var mass = ode.dMass()
  mass.massSetBoxTotal(1.0, 1.0, 1.0, 1.0)
  physics.body.bodySetMass(mass)

  # TODO: send geometry (AABB) to graphics system - AddGeometryMessage


method process*(self: ref SandboxPhysicsSystem, message: ref SystemReadyMessage) =
  # We want to reset our scene when physics system is ready.
  new(ResetSceneMessage).send(self)


method process*(self: ref SandboxPhysicsSystem, message: ref ResetSceneMessage) =
  logging.debug "Resetting scene"

  if not self.plane.isInitialized:
    self.plane = newEntity()
    (ref CreateEntityMessage)(entity: self.plane).send("network")
    let physics = new(PlanePhysics)
    self.init(physics)
    self.plane[ref Physics] = physics

    let position = physics.body.bodyGetPosition()
    (ref SyncPositionMessage)(entity: self.plane, x: position[0], y: position[1], z: position[2]).send("network")

  # first, delete all existing boxes
  for box in self.boxes:
    (ref DeleteEntityMessage)(entity: box).send("network")
    box.delete()

  self.boxes = @[]

  # define boxes locations
  let boxesCoords = @[
    (0.0, 1.0, -10.0),
    (-2.0, 1.0, -10.0),
    (2.0, 1.0, -10.0),
    (-1.0, 2.5, -10.0),
    (1.0, 2.5, -10.0),
    (0.0, 4.0, -10.0),
  ]

  var box: Entity

  for coords in boxesCoords:
    # create box at each position and send its coordinates
    box = newEntity()
    (ref CreateEntityMessage)(entity: box).send("network")

    let physics = BoxPhysics.new()
    self.init(physics)
    box[ref Physics] = physics

    logging.debug &"Setting position: {coords[0]} {coords[1]} {coords[2]}"
    box[ref Physics].body.bodySetPosition(coords[0], coords[1], coords[2])
    (ref SyncPositionMessage)(entity: box, x: coords[0], y: coords[1], z: coords[2]).send("network")
    # TODO: add RotateMessage
    # cube[ref Physics].body.bodySetQuaternion([1.0, 1.0, 1.0, 0])
    # let quat = cube[ref Physics].body.bodyGetQuaternion()
    # (ref SyncRotationMessage)(entity: cube, quaternion: [quat[0], quat[1], quat[2], quat[3]]).send("network")

    self.boxes.add(box)

  logging.debug "Scene loaded"
