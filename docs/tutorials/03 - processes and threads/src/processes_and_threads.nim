# processes_and_threads.nim
import c4/processes
import c4/threads
import c4/logging

when isMainModule:
  const
    network = ThreadID(1)
    physics = ThreadID(2)
    video = ThreadID(3)

  info "running common code"

  spawnProcess "server":
    info "running server"

    spawnThread physics:
      info "running thread", threadID, threadName="physics"
      sleep 200

    spawnThread network:
      info "running thread", threadID, threadName="network"
      sleep 200

    joinActiveThreads()

  spawnProcess "client":
    info "running client"

    spawnThread video:
      info "running thread", threadID, threadName="physics"
      sleep 200

    spawnThread network:
      info "running thread", threadID, threadName="network"
      sleep 200

    joinActiveThreads()

  joinProcesses()
  info "all processes finished"
