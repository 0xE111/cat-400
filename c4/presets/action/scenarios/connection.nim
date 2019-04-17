# TODO: move specific messages here?
import logging
import tables
import strformat

import ../../../lib/ode/ode

import ../../../config
import ../../../utils/loading
import ../../../core/messages
import ../../../systems as systems_module
import ../../../systems/network/enet
import ../../../systems/physics/ode as ode_physics
import ../../../core/entities

import ../systems/network
import ../systems/physics
import ../messages as action_messages


method process*(self: ref ActionClientNetworkSystem, message: ref ConnectionOpenedMessage) =
  ## Prepare scene on client side, that's why we send this message to video system.
  message.send(systems["video"])


method process*(self: ref ActionServerNetworkSystem, message: ref ConnectionOpenedMessage) =
  ## When new peer connects, we want to create a corresponding entity, thus we forward this message to physics system.
  message.send(systems["physics"])


method process*(self: ref ActionPhysicsSystem, message: ref ConnectionOpenedMessage) =
  ## When new peer connects, we want to create a corresponding Entity for him.
  ## We also need to send all world information to new peer.

  let player = newEntity()  # create new Entity
  player[ref Physics] = ActionPhysics.new()
  player[ref Physics].body.bodySetPosition(0.0, 0.0, 0.0)

  var mass = ode.dMass()
  mass.addr.massSetBoxTotal(10.0, 1.0, 1.0, 1.0)
  player[ref Physics].body.bodySetMass(mass.addr)

  # send new entity to all peers
  (ref CreateEntityMessage)(entity: player).send(systems["network"])

  let position = player[ref Physics].body.bodyGetPosition()[]
  (ref SyncPositionMessage)(entity: player, x: position[0], y: position[1], z: position[2]).send(systems["network"])

  let rotation = player[ref Physics].body.bodyGetQuaternion()[]
  (ref SyncRotationMessage)(entity: player, quaternion: rotation).send(systems["network"])

  # send impersonation message to new peer
  self.impersonationsMap[message.peer] = player  # add it to mapping
  (ref ImpersonationMessage)(entity: player, recipient: message.peer).send(systems["network"])

  # send all scene data to new peer
  logging.debug &"Sending all scene data to peer {$(message.peer[])}"
  for entity, physics in getComponents(ref Physics).pairs():
    if entity == player:
      # player entity was already broadcasted
      continue

    (ref CreateEntityMessage)(entity: entity, recipient: message.peer).send(systems["network"])

    let position = physics.body.bodyGetPosition()[]
    (ref SyncPositionMessage)(entity: entity, x: position[0], y: position[1], z: position[2], recipient: message.peer).send(systems["network"])

    let rotation = physics.body.bodyGetQuaternion()[]
    (ref SyncRotationMessage)(entity: entity, quaternion: rotation, recipient: message.peer).send(systems["network"])


method process*(self: ref ActionClientNetworkSystem, message: ref ConnectionClosedMessage) =
  ## Forward this message to video system in order to unload the scene
  procCall self.as(ref ClientNetworkSystem).process(message)  # trigger mappings
  message.send(systems["video"])

  logging.debug "Flushing local entities"
  entities.flush()


method process*(self: ref ActionServerNetworkSystem, message: ref ConnectionClosedMessage) =
  ## When peer disconnects, we want to delete corresponding entity, thus we forward this message to physics system.
  procCall self.as(ref ServerNetworkSystem).process(message)  # trigger mappings
  message.send(systems["physics"])


method process*(self: ref ActionPhysicsSystem, message: ref ConnectionClosedMessage) =
  ## When peer disconnects, we want to remove a corresponding Entity.
  logging.debug &"Removing entity"
  let entity = self.impersonationsMap[message.peer]

  entity.delete()  # delete Entity
  (ref DeleteEntityMessage)(entity: entity).send(systems["network"])

  self.impersonationsMap.del(message.peer)  # exclude peer's Entity from mapping
