import typetraits
import strformat

import "../../core/messages"
import "../../utils/stringify"
import "../../core/entities"


type
  QuitMessage* = object of Message  ## this message is a signal to disconnect and terminate process

  WindowResizeMessage* = object of Message
    width*, height*: int

  EntityMessage* = object of Message
    ## A message that is related to (or affects) an Entity.
    ## This message should not be used directly. Instead, inherit your own message type from this one.
    entity*: Entity

  CreateEntityMessage* = object of EntityMessage
  DeleteEntityMessage* = object of EntityMessage


messages.register(QuitMessage)
strMethod(QuitMessage)

messages.register(WindowResizeMessage)
method `$`*(self: ref WindowResizeMessage): string = &"{self[].type.name}: {self.width}x{self.height}"

# TODO: is this needed?
messages.register(EntityMessage)
method `$`*(self: ref EntityMessage): string = &"{self[].type.name}: {self.entity}"

messages.register(CreateEntityMessage)
method `$`*(self: ref CreateEntityMessage): string = &"{self[].type.name}: {self.entity}"
messages.register(DeleteEntityMessage)
method `$`*(self: ref DeleteEntityMessage): string = &"{self[].type.name}: {self.entity}"
