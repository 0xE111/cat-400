import c4/entities
import c4/systems
import c4/systems/network/enet

import ../systems/network
import ../systems/video


method process(self: ref network.ClientNetworkSystem, message: ref CreateEntityMessage) =
    ## Sends message to video system
    procCall self.as(ref enet.ClientNetworkSystem).process(message)  # generate remote->local entity mapping
    message.send("video")


method process(self: ref video.VideoSystem, message: ref CreateEntityMessage) =
    ## Here we should create an entity. This is app-specific action, so developer should redefine it.
    raise newException(LibraryError, "Method not implemented")


method process(self: ref network.ClientNetworkSystem, message: ref DeleteEntityMessage) =
    ## Deletes an entity when server asks to do so.
    procCall self.as(ref enet.ClientNetworkSystem).process(message)  # update remote->local entity mapping
    message.entity.delete()
