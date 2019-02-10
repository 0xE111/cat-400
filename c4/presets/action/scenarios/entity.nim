import ../../../core/entities
import ../../../config
import ../../../systems
import ../../../systems/network/enet

import ../systems/network
import ../systems/video


method process(self: ref ActionClientNetworkSystem, message: ref CreateEntityMessage) =
    ## Sends message to video system
    procCall self.as(ref NetworkSystem).process(message)  # generate remote->local entity mapping
    message.send(config.systems.video)


method process(self: ref ActionVideoSystem, message: ref CreateEntityMessage) =
    ## Here we should create an entity. This is app-specific action, so developer should redefine it.
    assert mode == client

    raise newException(LibraryError, "Method not implemented")
    # message.entity[ref Video] = Video.new()


method process(self: ref ActionClientNetworkSystem, message: ref DeleteEntityMessage) =
    ## Deletes an entity when server asks to do so.
    procCall self.as(ref ClientNetworkSystem).process(message)  # generate remote->local entity mapping
    message.entity.delete()