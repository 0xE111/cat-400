import logging
import strformat

import c4.core.messages
import c4.presets.default.messages as default_messages
import c4.core.entities
import c4.core.states

import c4.systems
import c4.systems.network.enet as network
import c4.systems.physics.ode as physics

import c4.wrappers.ode.ode

import c4.presets.default.states as default_states
import c4.config

import c4.presets.action.messages as action_messages
import c4.presets.action.systems.physics as action_physics


method onEnter(self: ref LoadingServerState) =
  var cube: Entity

  for i in 1..10:
    cube = newEntity()
    (ref AddEntityMessage)(entity: cube).send(config.systems.network)

    var physics = new(ActionPhysics)
    config.systems.physics.initComponent(physics)
    physics.body.bodySetPosition(0.0, 0.0, -i.float * 6)

    var mass = ode.dMass()
    mass.addr.massSetBoxTotal(10.0, 1.0, 1.0, 1.0)
    physics.body.bodySetMass(mass.addr)

    cube[ref Physics] = physics

    var position = physics.body.bodyGetPosition()
    (ref PhysicsMessage)(entity: cube, x: position[][0], y: position[][1], z: position[][2]).send(config.systems.network)

  logging.debug "Server scene loaded"

  config.state.switch(new(RunningServerState))
