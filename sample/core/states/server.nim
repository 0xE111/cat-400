from logging import debug

import c4.core.messages
import c4.presets.default.messages as default_messages
import c4.core.entities
import c4.core.states

import c4.systems
import c4.systems.network
import c4.systems.physics

import c4.presets.default.states as default_states
import c4.config

import "../messages" as custom_messages


method onEnter(self: ref LoadingServerState) =
  var cube: Entity

  for i in 1..60:
    cube = newEntity()
    (ref AddEntityMessage)(entity: cube).send(config.systems.network)

    cube[ref Physics] = (ref Physics)(
      x: 0.float,
      y: 0.float,
      z: -i.float * 6,
    )
    (ref PhysicsMessage)(entity: cube, physics: cube[ref Physics]).send(config.systems.network)

  logging.debug "Server scene loaded"

  config.state.switch(new(RunningServerState))
