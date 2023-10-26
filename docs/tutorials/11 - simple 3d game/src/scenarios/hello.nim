import c4/threads
import c4/logging
import c4/systems/network/net
import c4/entities
import c4/systems/physics/ode
import c4/lib/ode/ode
import c4/lib/ogre/ogre

import ../systems/network
import ../systems/video
import ../systems/physics
import ../threads
import ../messages


method receive*(self: ref network.ServerNetworkSystem, message: ref HelloMessage) =
  message.send(physicsThread)

method process*(self: ref physics.PhysicsSystem, message: ref HelloMessage) =
  info "physics received hello message"

  # when receiving HelloMessage from new client, send him whole world information
  for entity, physics in getComponents(ref physics.Physics):
    (ref EntityCreateMessage)(entity: entity).send(networkThread)
    let position = physics.body.bodyGetPosition()
    (ref EntityMoveMessage)(entity: entity, x: position[0], y: position[1], z: position[2]).send(networkThread)

  (ref ImpersonateMessage)(entity: self.player).send(networkThread)

method receive*(self: ref network.ClientNetworkSystem, message: ref ImpersonateMessage) =
  message.entity = self.entitiesMap[message.entity]  # TODO: make it automatic
  message.send(videoThread)

method process*(self: ref VideoSystem, message: ref ImpersonateMessage) =
  message.entity[ref Video].node.attachObject(self.camera)
  debug "camera attached to entity", entity=message.entity
