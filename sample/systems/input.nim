from c4.systems.input import InputSystem
import sdl2.sdl
from strformat import `&`
from c4.core.messages import Message, `$`
from "../core/messages" as custom_messages import CustomMessage
from logging import debug


type
  CustomInputSystem* = object of InputSystem


# method handle*(self: ref CustomInputSystem, event: sdl.Event): ref Message =
#   case event.kind
#     of sdl.QUIT:
#       result = new(ref CustomMessage)
#     else:
#       discard

#   if result != nil:
#     logging.debug(&"Handled event -> new message {result}")
