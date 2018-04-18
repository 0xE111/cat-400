from logging import debug

import c4.core.messages
import c4.defaults.messages as default_messages
import c4.core.entities
import c4.core.states

import c4.systems
import c4.systems.network
import c4.systems.physics

import c4.defaults.states as default_states
import c4.config

import "../messages" as custom_messages


method onEnter(self: ref LoadingServerState) =
  var cube: Entity

  for i in 1..30:
    cube = newEntity()
    (ref AddEntityMessage)(entity: cube).send(config.systems.network)

    cube[ref Physics] = (ref Physics)(
      x: @[i.float, i.float/2, 0, -i.float/2, -i.float, -i.float/2, 0, i.float/2][i mod 8],
      y: i.float,
      z: @[0.0, -i.float/2, -i.float, -i.float/2, 0, i.float/2, i.float, i.float/2][i mod 8],
    )
    (ref PhysicsMessage)(entity: cube, physics: cube[ref Physics]).send(config.systems.network)

  logging.debug "Server scene loaded"

  config.state.switch(new(RunningServerState))
