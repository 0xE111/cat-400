from entities import Entity
import "../wrappers/msgpack/msgpack"


type
  Peer* = object {.inheritable.}
  Message* = object {.inheritable.}
    peer*: ref Peer  # message sender


register(Message)  # TODO: move to network?

method `$`*(message: ref Message): string {.base.} = "Message"

proc isExternal*(self: ref Message): bool =
  not self.peer.isNil
