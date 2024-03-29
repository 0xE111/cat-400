# main.nim
import sdl2

import c4/threads as c4threads
import c4/systems
import c4/systems/video/sdl as sdlvideo
import c4/systems/input/sdl as sdlinput
import c4/logging

import ./systems/input
import ./systems/video


when isMainModule:
  spawnThread c4threads.ThreadID(1):
    var videoSystem = new(video.VideoSystem)

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

  spawnThread c4threads.ThreadID(2):
    var inputSystem = new(input.InputSystem)
    inputSystem.process(new(InputInitMessage))
    inputSystem.run(frequency=30)

  joinActiveThreads()
