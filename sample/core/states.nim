from logging import debug

import c4.core.messages
import c4.core.messages.builtins
import c4.core.entities

import c4.systems.network
import c4.systems.physics

import c4.server


method onEnter(self: ref LoadingState) =
  let player = newEntity()  # create new entity
  (ref AddEntityMessage)(entity: player).broadcast()  # send message

  player[ref Physics] = (ref Physics)(x: 1, y: 2, z: 3)  # init physics for player
  (ref PhysicsMessage)(entity: player, physics: player[ref Physics]).broadcast()
  player[ref Physics].x = 1  # update player physics
  (ref PhysicsMessage)(entity: player, physics: player[ref Physics]).broadcast()

  let cube = newEntity()
  (ref AddEntityMessage)(entity: cube).broadcast()

  cube[ref Physics] = (ref Physics)(x: 0, y: 0, z: -5)
  (ref PhysicsMessage)(entity: cube, physics: player[ref Physics]).broadcast()

  logging.debug("Server scene loaded")
