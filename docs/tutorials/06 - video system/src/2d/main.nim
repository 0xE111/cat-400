# main.nim
import sdl2

import c4/threads as c4threads
import c4/processes
import c4/systems
import c4/systems/video/sdl as c4sdl
import c4/logging


import systems/video


when isMainModule:
  spawnProcess "server":
    spawnThread c4threads.ThreadID(1):
      var videoSystem = video.VideoSystem.new()

      videoSystem.process(
        (ref VideoInitMessage)(
          windowTitle: "My awesome game",
          windowWidth: 640,
          windowHeight: 480,
          windowX: SDL_WINDOWPOS_CENTERED,
          windowY: SDL_WINDOWPOS_CENTERED,
          flags: (SDL_WINDOW_SHOWN or SDL_WINDOW_RESIZABLE or SDL_WINDOW_OPENGL).uint32,
        )
      )

      videoSystem.run(frequency=60)

    joinActiveThreads()

  joinProcesses()
