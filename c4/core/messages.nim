## Message is a base unit for communication between systems.

from entities import Entity
import "../wrappers/msgpack/msgpack"


type
  Peer* = object {.inheritable.}

  Message* = object {.inheritable.}
    ## Every message contains a reference to a sender (Peer).
    ## Network system should populate the `peer` field when receiving Message from remote machine.
    ## You need to call `register` or `registerWithStringify` so that msgpack4nim knows how to (de)serialize your custom message.
    peer*: ref Peer  ## Message sender; nil means that the message is local.
  
  EntityMessage* = object of Message
    ## A message that is related to (or affects) an Entity - i.e. AddEntityMessage, RotateEntityMessage etc.
    entity*: Entity


proc isExternal*(self: ref Message): bool =
  ## Check whether this message is local or from external Peer
  not self.peer.isNil

template registerWithStringify*(T: typedesc) =
  ## Just a shortcut which registers subclass of Message and populates its 
  register(Message, T)
  method `$`(self: ref T): string = T.name


register(Message)  # teach msgpack4nim to pack Message and its subclasses
method `$`*(message: ref Message): string {.base.} = "Message"
