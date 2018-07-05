## Message is a base unit for communication between systems.
import hashes

import "../wrappers/msgpack/msgpack"
export msgpack.pack_type, msgpack.unpack


type
  Peer* = object {.inheritable.}  ## \
  ## This is a type for addressing an entity in network connection. ``Peer`` may refer to a server or one of its clients.

  Message* = object {.inheritable.}
    ## Every message contains a reference to a sender (Peer).
    ## Network system should populate the `peer` field when receiving Message from remote machine.
    ## You need to call `core.messages.register` so that msgpack4nim knows how to (de)serialize your custom message.
    sender*: ref Peer  ## Message sender; nil means that the message is local.
    recipient*: ref Peer  ## Message recipient; nil means that the message should be broadcasted.


proc isLocal*(self: ref Message): bool =
  ## Check whether this message is local or from external Peer
  self.sender.isNil

proc hash*(self: ref Peer): Hash =
  result = self[].addr.hash
  # result = !$result

# ---- msgpack stuff ----
msgpack.register(Message)  # teach msgpack4nim to pack Message and its subclasses
method `$`*(self: ref Message): string {.base.} = "Message"

template register*(T: typedesc) =
  ## Registers Message subtype in msgpack
  msgpack.register(Message, T)
