import sdl2
import tables

import ../../logging
import ../../messages
import ../../systems
import ../../loop


type
  InputSystem* = object of System
    event: Event  # temporary storage for event when calling pollEvent()

  InputSystemError* = object of LibraryError

  InputInitMessage* = object of Message

  WindowQuitMessage* = object of Message


template handleError*(message: string) =
  let error = getError()
  fatal message, error
  raise newException(InputSystemError, message & ": "  & $error)


InputInitMessage.register()
WindowQuitMessage.register()


method process*(self: ref InputSystem, message: ref InputInitMessage) =
  withLog(DEBUG, "initializing input"):
    if initSubSystem(INIT_EVENTS) != 0: handleError("failed to initialize events")

method dispose*(self: ref InputSystem) =
  quitSubSystem(INIT_EVENTS)


# proc `$`*(event: Event): string = $event.kind



# ---- workflow methods ----
# method init*(self: ref InputSystem) =
#   logging.debug &"Initializing {self[].type.name}"

#   try:
#     sleep 500  # wait for SDL VIDEO system to initialize (in case of race condition)
#     if wasInit(INIT_VIDEO) == 0:
#       # INIT_VIDEO implies INIT_EVENTS -> don't initialize events if video already initialized
#       logging.debug "Initializing SDL events"
#       if initSubSystem(INIT_EVENTS) != 0:
#         raise newException(LibraryError, &"Could not init {self.type.name}: {getError()}")

#   except LibraryError:
#     quitSubSystem(INIT_EVENTS)
#     logging.fatal(getCurrentExceptionMsg())
#     raise

method handleEvent*(self: ref InputSystem, event: Event) {.base.} =
  case event.kind
    of QuitEvent:
      raise newException(BreakLoopException, "")
    of WINDOWEVENT:
      case event.window.event
        of WINDOWEVENT_SIZE_CHANGED:
          #   width: event.window.data1,
          #   height: event.window.data2,
          discard
        else:
          discard
    # of KEYDOWN:
    #   case event.key.keysym.sym
    #     of K_c:
    #       ...
    else:
      discard

method handleKeyboardState*(
  self: ref InputSystem,
  keyboard: ptr array[0 .. SDL_NUM_SCANCODES.int, uint8],
) {.base.} =
  discard

method update*(self: ref InputSystem, dt: float) =
  while pollEvent(self.event) != False32:
    self.handleEvent(self.event)

  self.handleKeyboardState(getKeyboardState(nil))


when isMainModule:
  import unittest
  import ../../threads

  suite "System tests":
    test "Running inside thread":
      spawnThread ThreadID(1):
        let system = new(InputSystem)
        system.process(new InputInitMessage)
        system.run(frequency=30)

      joinActiveThreads()
