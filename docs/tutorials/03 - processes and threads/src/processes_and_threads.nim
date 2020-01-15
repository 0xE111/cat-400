# processes_and_threads.nim
import strformat

import c4/[processes, threads]


when isMainModule:
  echo &"Running {processName()} process"

  run("server") do:
    spawn("physics") do:
      echo &" - Thread {threadName()}"
      sleep 2000

    spawn("network") do:
      echo &" - Thread {threadName()}"
      sleep 2000

    threads.joinAll()  # let's specify module explicitly to not get confused

  run("client") do:
    spawn("video") do:
      echo &" - Thread {threadName()}"
      sleep 2000

    spawn("network") do:
      echo &" - Thread {threadName()}"
      sleep 2000

    threads.joinAll()

  processes.dieTogether()  # let's specify module explicitly to not get confused
