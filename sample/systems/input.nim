import sdl2.sdl
from strformat import `&`
from logging import debug

import c4.core.messages
from c4.systems.input import InputSystem, handle
import "../core/messages" as custom_messages


type
  CustomInputSystem* = object of InputSystem


method handle*(self: ref CustomInputSystem, event: sdl.Event): ref Message =
  case event.kind
    of sdl.MOUSEBUTTONDOWN:
      result = (ref LoadSceneMessage)()
    else:
      # fallback to default implementation
      result = procCall(((ref InputSystem)self).handle(event))

  if result != nil:
    logging.debug(&"Event produced new message: {result}")
