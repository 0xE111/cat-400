## Message is a base unit for communication between systems.

import entities
import "../wrappers/msgpack/msgpack"
export msgpack.pack_type, msgpack.unpack


type
  Peer* = object {.inheritable.}

  Message* = object {.inheritable.}
    ## Every message contains a reference to a sender (Peer).
    ## Network system should populate the `peer` field when receiving Message from remote machine.
    ## You need to call `core.messages.register` so that msgpack4nim knows how to (de)serialize your custom message.
    peer*: ref Peer  ## Message sender; nil means that the message is local.
  
  EntityMessage* = object of Message
    ## A message that is related to (or affects) an Entity - i.e. AddEntityMessage, RotateEntityMessage etc.
    entity*: Entity


proc isExternal*(self: ref Message): bool =
  ## Check whether this message is local or from external Peer
  not self.peer.isNil

# ---- msgpack stuff ----
msgpack.register(Message)  # teach msgpack4nim to pack Message and its subclasses
method `$`*(message: ref Message): string {.base.} = "Message"

template register*(T: typedesc) =
  ## Registers Message subtype in msgpack
  msgpack.register(Message, T)
