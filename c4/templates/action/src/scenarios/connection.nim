when defined(nimHasUsed):
  {.used.}

# TODO: move specific messages here?
import logging
import tables
import strformat

import c4/lib/ode/ode as odelib
import c4/messages as c4messages
import c4/systems
import c4/systems/network/enet
import c4/systems/physics/ode
import c4/entities

import ../systems/network
import ../systems/physics
import ../systems/video
import ../messages


method process*(self: ref network.ClientNetworkSystem, message: ref ConnectionOpenedMessage) =
  ## Prepare scene on client side, that's why we send this message to video system.
  message.send("video")


method process*(self: ref network.ServerNetworkSystem, message: ref ConnectionOpenedMessage) =
  ## When new peer connects, we want to create a corresponding entity, thus we forward this message to physics system.
  message.send("physics")


method process*(self: ref physics.PhysicsSystem, message: ref ConnectionOpenedMessage) =
  ## When new peer connects, we want to create a corresponding Entity for him.
  ## We also need to send all world information to new peer.

  let player = newEntity()  # create new Entity
  let phys = new(BoxPhysics)
  self.init(phys)
  player[ref physics.Physics] = phys
  player[ref physics.Physics].body.bodySetPosition(0.0, 1.0, -5.0)

  # send new entity to all peers
  (ref CreatePlayerEntityMessage)(entity: player).send("network")

  let position = player[ref physics.Physics].body.bodyGetPosition()[]
  (ref SyncPositionMessage)(entity: player, x: position[0], y: position[1], z: position[2]).send("network")

  let rotation = player[ref physics.Physics].body.bodyGetQuaternion()[]
  (ref SyncRotationMessage)(entity: player, quaternion: rotation).send("network")

  # send impersonation message to new peer
  self.impersonationsMap[message.peer] = player  # add it to mapping
  (ref ImpersonationMessage)(entity: player, recipient: message.peer).send("network")

  # send all scene data to new peer
  logging.debug &"Sending all scene data to peer {$(message.peer[])}"

  (ref CreatePlaneEntityMessage)(entity: self.plane, recipient: message.peer).send("network")
  let planePosition = self.plane[ref physics.Physics].body.bodyGetPosition()[]
  (ref SyncPositionMessage)(entity: self.plane, x: planePosition[0], y: planePosition[1], z: planePosition[2], recipient: message.peer).send("network")

  for box in self.boxes:
    (ref CreateBoxEntityMessage)(entity: box, recipient: message.peer).send("network")

    let physics = box[ref physics.Physics]

    let position = physics.body.bodyGetPosition()[]
    (ref SyncPositionMessage)(entity: box, x: position[0], y: position[1], z: position[2], recipient: message.peer).send("network")

    let rotation = physics.body.bodyGetQuaternion()[]
    (ref SyncRotationMessage)(entity: box, quaternion: rotation, recipient: message.peer).send("network")  # TODO: make `recipient` attrubute of `send()`?


method process*(self: ref network.ClientNetworkSystem, message: ref ConnectionClosedMessage) =
  ## Forward this message to video system in order to unload the scene
  procCall self.as(ref enet.ClientNetworkSystem).process(message)  # trigger mappings
  message.send("video")

  logging.debug "Flushing local entities"
  entities.flush()


method process*(self: ref network.ServerNetworkSystem, message: ref ConnectionClosedMessage) =
  ## When peer disconnects, we want to delete corresponding entity, thus we forward this message to physics system.
  procCall self.as(ref enet.ServerNetworkSystem).process(message)  # trigger mappings
  message.send("physics")


method process*(self: ref physics.PhysicsSystem, message: ref ConnectionClosedMessage) =
  ## When peer disconnects, we want to remove a corresponding Entity.
  logging.debug &"Removing entity"
  let entity = self.impersonationsMap[message.peer]

  entity.delete()  # delete Entity
  (ref DeleteEntityMessage)(entity: entity).send("network")

  self.impersonationsMap.del(message.peer)  # exclude peer's Entity from mapping


method process*(self: ref VideoSystem, message: ref SystemReadyMessage) =
  # connect to server as soon as video system is loaded
  (ref ConnectMessage)(address: ("localhost", 11477'u16)).send("network")


method process*(self: ref VideoSystem, message: ref SystemQuitMessage) =
  # disconnect as soon as video system is unloaded
  new(DisconnectMessage).send("network")


method process*(self: ref VideoSystem, message: ref ConnectionOpenedMessage) =
  ## Load skybox when connection is established
  logging.debug "Loading skybox"


method process*(self: ref VideoSystem, message: ref ConnectionClosedMessage) =
  ## Unload everything when connection is closed
  logging.debug "Unloading skybox"

  # self.skybox.removeNode()
