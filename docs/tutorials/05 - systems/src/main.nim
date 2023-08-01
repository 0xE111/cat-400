# main.nim
import threadpool
import strformat
import c4/threads
import c4/processes

# import our newly created system
import systems/fps

when isMainModule:
  run("server"):
    spawnThread("fps"):
      echo &" - Thread {threadName}"
      var system = FpsSystem()
      system.init()
      system.run()

    sync()
