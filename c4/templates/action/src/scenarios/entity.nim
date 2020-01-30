when defined(nimHasUsed):
    {.used.}

import c4/types
import c4/entities
import c4/systems
import c4/systems/network/enet
import c4/systems/video/ogre

import ../systems/network
import ../systems/video
import ../messages


method process(self: ref network.ClientNetworkSystem, message: ref CreateEntityMessage) =
    ## Sends message to video system
    procCall self.as(ref enet.ClientNetworkSystem).process(message)  # generate remote->local entity mapping
    message.send("video")


method process*(self: ref video.VideoSystem, message: ref CreateEntityMessage) =
    # this will capture all `CreateEntity` messages by default and create box graphics
    let video = new(BoxVideo)
    self.init(video)
    message.entity[ref Video] = video


method process*(self: ref video.VideoSystem, message: ref CreatePlaneEntityMessage) =
    let video = new(PlaneVideo)
    self.init(video)
    message.entity[ref Video] = video



method process(self: ref network.ClientNetworkSystem, message: ref DeleteEntityMessage) =
    ## Deletes an entity when server asks to do so.
    procCall self.as(ref enet.ClientNetworkSystem).process(message)  # update remote->local entity mapping
    message.entity.delete()
