# src/messages.nim
import c4/messages
import c4/logging


type RunMessage = object of Message
  data: string

method name(msg: ref Message): string {.base.} = "Message"
method name(msg: ref RunMessage): string = "RunMessage"

var
  message: ref Message  # here we will assign message subtype
  packed: string  # here we will store packed message
  unpacked: ref Message  # here we will unpack message

register RunMessage  # now we can serialize RunMessage

message = (ref RunMessage)(data: "test data")  # here message is of type `ref Message`, but in fact we assigned `ref RunMessage` to this variable
assert message.name == "RunMessage"

packed = message.msgpack()
info "packed message", packed
assert stringify(packed) == "1 [ \"test data\" ] "  # `1` means that we packed message type (1 for RunMessage) together with message data

# ... send `packed` over network / save it on disk / whatever ...

# now it's time to restore the message
unpacked = packed.msgunpack()  # when unpacking, we use value `1` to understand that real runtime type of `unpacked` should be `ref RunMessage`
info "unpacked message", unpacked
assert unpacked of ref RunMessage  # runtime type is preserved
assert unpacked.name == "RunMessage"
