# TODO: move specific messages here?
import logging
import tables
import strformat

import "../../../config"
import "../../../utils/loading"
import "../../../core/messages"
import "../../../systems"
import "../../../systems/network/enet"
import "../../../systems/physics/ode" as ode_physics
import "../../../core/entities"

import "../../../wrappers/ode/ode"
import "../../../wrappers/ode/ode/helpers"

import "../systems/network"
import "../systems/physics"
import "../messages" as action_messages


# TODO: combine next 2 methods?
method process*(self: ref ActionNetworkSystem, message: ref ConnectionOpenedMessage) =
  ## When new peer connects, we want to create a corresponding entity, thus we forward this message to physics system.
  ## 
  ## Also we need to prepare scene on client side, that's why we send this message to video system as well.

  if mode == server:
    message.send(config.systems.physics)

  elif mode == client:
    message.send(config.systems.video)

method process*(self: ref ActionPhysicsSystem, message: ref ConnectionOpenedMessage) =
  ## When new peer connects, we want to create a corresponding Entity for him.
  ## We also need to send all world information to new peer.
  
  var physics = new(ActionPhysics)
  config.systems.physics.initComponent(physics)
  physics.body.bodySetPosition(0.0, 0.0, 0.0)

  var mass = ode.dMass()
  mass.addr.massSetBoxTotal(10.0, 1.0, 1.0, 1.0)
  physics.body.bodySetMass(mass.addr)

  let playerEntity = newEntity()  # create new Entity
  playerEntity[ref Physics] = physics
  
  self.peersEntities[message.peer] = playerEntity  # add it to mapping

  # send all scene data
  for entity, physics in getComponents(ref Physics).pairs():
    (ref CreateEntityMessage)(entity: entity, recipient: message.peer).send(config.systems.network)
    let position = physics.body.getPosition()
    (ref SetPositionMessage)(entity: entity, x: position.x, y: position.y, z: position.z, recipient: message.peer).send(config.systems.network)

    # TODO: send "rotate" message

  # # send "impersonate" message for playerEntity
  # (ref ImpersonateMessage)(entity: playerEntity).send(config.systems.network, receiver=message.peer)

method process*(self: ref ActionNetworkSystem, message: ref ConnectionClosedMessage) =
  ## When peer disconnects, we want to delete corresponding entity, thus we forward this message to physics system.
  ## 
  ## Also we need to unload scene on client side, that's why we send this message to video system as well.

  procCall self.as(ref NetworkSystem).process(message)

  if mode == server:
    message.send(config.systems.physics)

  elif mode == client:
    message.send(config.systems.video)

    logging.debug "Flushing local entities"
    entities.flush()

method process*(self: ref ActionPhysicsSystem, message: ref ConnectionClosedMessage) =
  ## When peer disconnects, we want to remove a corresponding Entity.

  logging.debug &"Received {message} message, removing entity"
  self.peersEntities[message.peer].delete()  # delete Entity # TODO: physics not deleted!
  self.peersEntities.del(message.peer)  # exclude peer's Entity from mapping
