import c4/systems
import c4/systems/network/net
import c4/systems/video/sdl as sdl_video
import c4/systems/input/sdl as sdl_input
import c4/processes
import c4/logging
import c4/threads

import sdl2

import ./systems/input
import ./threads as thread_names

when isMainModule:

  spawnProcess "server":

    spawnThread networkThread:
      threadName = "network"

      var network = new(ServerNetworkSystem)
      network.process((ref ServerInitMessage)(port: 6543))
      network.run()

    joinActiveThreads()

  spawnProcess "client":

    spawnThread networkThread:
      threadName = "network"

      var network = new(ClientNetworkSystem)
      network.process(new(ClientInitMessage))
      network.run()

    spawnThread videoThread:
      threadName = "video"

      var videoSystem = new(VideoSystem)
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

    spawnThread inputThread:
      threadName = "input"

      var inputSystem = new(input.InputSystem)
      inputSystem.process(new(InputInitMessage))
      inputSystem.run(frequency=30)

    joinActiveThreads()

  joinProcesses()
