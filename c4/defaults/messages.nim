import typetraits
from strformat import `&`

import "../wrappers/msgpack/msgpack"
import "../core/messages"


type
  QuitMessage* = object of Message  ## this message is a signal to disconnect and terminate process
  WindowResizeMessage* = object of Message
    width*, height*: int


registerWithStringify(QuitMessage)

register(Message, WindowResizeMessage)
method `$`*(self: ref WindowResizeMessage): string = &"WindowResize {self.width}x{self.height}"
