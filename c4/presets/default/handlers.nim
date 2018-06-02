import logging
import tables
import strformat

import "../../config"
import "../../core/states"
import "../../core/entities"
import "../../core/messages"
import "../../systems"
import "../../systems/network/enet"
import "../../systems/video/horde3d"

import messages as default_messages
import states as default_states


method store*(self: ref NetworkSystem, message: ref QuitMessage) =
  # by default network system sends all local incoming messages
  # however, we want to store and process QuitMessage
  procCall ((ref System)self).store(message)

method process*(self: ref NetworkSystem, message: ref QuitMessage) =
  self.disconnect()
  config.state.switch(new(FinalState))

method process*(self: ref VideoSystem, message: ref WindowResizeMessage) =
  self.updateViewport(message.width, message.height)

# TODO: send `CreateEntityMessage` and `DeleteEntityMessage` RELIABLE!

method process*(self: ref NetworkSystem, message: ref EntityMessage) =
  ## Every entity message requires converting remote Entity to local one.
  ## Call this in every method which processes `EntityMessage` subtypes.
  assert(message.isExternal, &"Message is not external: {message}")
  assert(self.entitiesMap.hasKey(message.entity), &"No local entity found for this remote entity: {message.entity}")
  message.entity = self.entitiesMap[message.entity]
  logging.debug "Mapped external Entity to local one"

method process*(self: ref NetworkSystem, message: ref CreateEntityMessage) =
  assert(not self.entitiesMap.hasKey(message.entity), &"Local entity already exists for this remote entity: {message.entity}")
  let entity = newEntity()
  self.entitiesMap[message.entity] = entity

method process*(self: ref NetworkSystem, message: ref DeleteEntityMessage) =
  assert(self.entitiesMap.hasKey(message.entity), &"No local entity found for this remote entity: {message.entity}")
  let entity = self.entitiesMap[message.entity]
  self.entitiesMap.del(message.entity)
  entity.delete()


