import typetraits
import strformat

import "../../core/messages"
import "../../utils/stringify"
import "../../core/entities"


type
  QuitMessage* = object of Message  ## \
    ## This message is a signal to disconnect and terminate systems and whole process
  SystemReadyMessage* = object of Message  ## \
    ## This message is sent to a system when it's initialization if complete

  EntityMessage* = object of Message
    ## A message that is related to (or affects) an Entity. This message should not be used directly. Instead, inherit your own message type from this one. When receiving this message from network system, remote entity will be seamlessly converted to local one.
    entity*: Entity

  CreateEntityMessage* = object of EntityMessage  ## \
    ## Message that notifies systems about entity creation.
  DeleteEntityMessage* = object of EntityMessage  ## \
    ## Message that notifies systems about entity deletion.


messages.register(QuitMessage)
strMethod(QuitMessage)

messages.register(SystemReadyMessage)
strMethod(SystemReadyMessage)

messages.register(CreateEntityMessage)
method `$`*(self: ref CreateEntityMessage): string = &"{self[].type.name}: {self.entity}"
messages.register(DeleteEntityMessage)
method `$`*(self: ref DeleteEntityMessage): string = &"{self[].type.name}: {self.entity}"
