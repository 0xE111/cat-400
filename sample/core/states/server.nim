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
  let player = newEntity()  # create new entity
  (ref AddEntityMessage)(entity: player).send(config.systems.network)  # send message

  player[ref Physics] = (ref Physics)(x: 1, y: 2, z: 3)  # init physics for player
  (ref PhysicsMessage)(entity: player, physics: player[ref Physics]).send(config.systems.network)
  player[ref Physics].x = 3  # update player physics
  (ref PhysicsMessage)(entity: player, physics: player[ref Physics]).send(config.systems.network)

  let cube = newEntity()
  (ref AddEntityMessage)(entity: cube).send(config.systems.network)

  cube[ref Physics] = (ref Physics)(x: 0, y: 0, z: -5)
  (ref PhysicsMessage)(entity: cube, physics: cube[ref Physics]).send(config.systems.network)

  logging.debug "Server scene loaded"

  config.state.switch(new(RunningServerState))
