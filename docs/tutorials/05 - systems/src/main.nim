# main.nim
import c4/threads
import c4/processes
import c4/logging
import c4/systems

# import our newly created system
import systems/fps

when isMainModule:
  spawnProcess "server":
    spawnThread ThreadID(1):
      info "running thread"
      var system = new(FpsSystem)
      system.run(frequency=30)

    joinActiveThreads()

  joinProcesses()
