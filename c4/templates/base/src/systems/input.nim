import sdl2/sdl as sdllib

import c4/systems/input/sdl

import ../messages


type InputSystem* = object of SdlInputSystem

# redefine input system methods below

# method handle*(self: ref InputSystem, event: Event) =
#   case event.kind
#     of QUIT:
#       new(SystemQuitMessage).send(@["video", "network"])
#     of WINDOWEVENT:
#       case event.window.event
#         of WINDOWEVENT_SIZE_CHANGED:
#           (ref WindowResizeMessage)(
#             width: event.window.data1,
#             height: event.window.data2,
#           ).send("video")
#         else:
#           discard
#     else:
#       procCall self.as(ref SdlInputSystem).handle(event)
