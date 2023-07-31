# processes_and_threads.nim
import strformat
import threadpool
import c4/[processes, threads]


when isMainModule:
  echo &"Running {processName} process"

  run("server"):
    spawnThread("physics"):
      echo &" - Thread {threadName}"
      sleep 2000

    spawnThread("network"):
      echo &" - Thread {threadName}"
      sleep 2000

    sync()  # let's specify module explicitly to not get confused

  run("client"):
    spawnThread("video"):
      echo &" - Thread {threadName}"
      sleep 2000

    spawnThread("network"):
      echo &" - Thread {threadName}"
      sleep 2000

    sync()

  processes.dieTogether()  # let's specify module explicitly to not get confused
  echo "All processes are finished"
