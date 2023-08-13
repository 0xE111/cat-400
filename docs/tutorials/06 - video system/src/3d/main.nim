# main.nim
import sdl2

import c4/threads as c4threads
import c4/processes
import c4/systems
import c4/systems/video/ogre
import c4/logging

import systems/video
import messages
import consts



when isMainModule:
  spawnProcess "server":
    spawnThread videoThread:
      var videoSystem = video.VideoSystem.new()

      # this will be processed immediately
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

      # this will be processed on first loop iteration
      (ref CreateEntityMessage)(x: 0, y: 0, z: -130).send(videoThread)

      videoSystem.run(frequency=60)

    joinActiveThreads()

  joinProcesses()
