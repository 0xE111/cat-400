import ./loop
import ./threads
import ./messages
import ./logging

type System* = object of RootObj

method process*(self: ref System, message: ref Message) {.base, gcsafe.} =
  warn "dropping unhandled message", message

method update*(self: ref System, dt: float) {.base, gcsafe.} =
  discard

method dispose*(self: ref System) {.base, gcsafe.} =
  discard

method run*(self: ref System, frequency: int = 60) {.base, gcsafe.} =
  var message: ref Message
  var received: bool

  loop frequency:
    withLog(TRACE, "system processing messages"):
      while true:
        (received, message) = channels[threadID].tryRecv()
        if not received:
          break
        debug "received message", message
        self.process(message)

    withLog(TRACE, "updating system state"):
      self.update(dt)

  debug "disposing system"
  self.dispose()


when isMainModule:
  import unittest

  const
    input = ThreadID(1)
    video = ThreadID(2)

  type
    InputSystem = object of System
      i: int
    VideoSystem = object of System
      i: int
    StopMessage = object of Message


  method update(self: ref InputSystem, dt: float) =
    echo "  updating input system"
    inc self.i
    if self.i > 10:
      new(StopMessage).send(video)
      raise newException(BreakLoopException, "")

  method update(self: ref VideoSystem, dt: float) =
    echo "updating video system"
    inc self.i

  method process(self: ref VideoSystem, message: ref StopMessage) =
    raise newException(BreakLoopException, "")

  suite "systems":

    test "two systems in threads":

      spawnThread input:
        var inputSystem = new(InputSystem)
        inputSystem.run(frequency=20)

      spawnThread video:
        var videoSystem = new(VideoSystem)
        videoSystem.run(frequency=100)

      joinActiveThreads()
      assert true
