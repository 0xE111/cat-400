# main.nim
import sdl2/sdl

import c4/threads
import c4/processes
import c4/systems
import c4/systems/video/sdl as c4sdl
import c4/logging


import systems/video


when isMainModule:
  spawnProcess "server":
    spawnThread "video":
      var videoSystem = VideoSystem.new()
      (ref SdlVideoInitMessage)(
        windowTitle: "My awesome game",
        windowWidth: 640,
        windowHeight: 480,
        windowX: WINDOWPOS_CENTERED,
        windowY: WINDOWPOS_CENTERED,
        flags: (sdl.WINDOW_SHOWN or sdl.WINDOW_RESIZABLE or sdl.WINDOW_VULKAN).uint32,
      ).send()
      videoSystem.run(frequency=60)

    threads.sync()

  processes.sync()
