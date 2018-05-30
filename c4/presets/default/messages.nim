import typetraits
import strformat

import "../../core/messages"
import "../../utils/stringify"


type
  QuitMessage* = object of Message  ## this message is a signal to disconnect and terminate process
  WindowResizeMessage* = object of Message
    width*, height*: int


messages.register(QuitMessage)
strMethod(QuitMessage)

messages.register(WindowResizeMessage)
method `$`*(self: ref WindowResizeMessage): string = &"WindowResize: {self.width}x{self.height}"
