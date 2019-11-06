when defined(nimHasUsed):
    {.used.}

import logging
import strformat

import c4/entities
import c4/systems
import c4/systems/network/enet
import c4/systems/video/ogre

import ../systems/network
import ../systems/video


method process(self: ref network.ClientNetworkSystem, message: ref CreateEntityMessage) =
    ## Sends message to video system
    procCall self.as(ref enet.ClientNetworkSystem).process(message)  # generate remote->local entity mapping
    message.send("video")


method process*(self: ref video.VideoSystem, message: ref CreateEntityMessage) =
    # sent by action network system when player connected and got new entity
    logging.debug &"Creating video component for entity {message.entity}"
    let video = new(BoxVideo)
    self.init(video)
    message.entity[ref Video] = video


method process(self: ref network.ClientNetworkSystem, message: ref DeleteEntityMessage) =
    ## Deletes an entity when server asks to do so.
    procCall self.as(ref enet.ClientNetworkSystem).process(message)  # update remote->local entity mapping
    message.entity.delete()
