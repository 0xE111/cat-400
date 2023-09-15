import times

import c4/processes
import c4/threads
import c4/logging

import c4/systems
import c4/systems/video/sdl as sdl_video
import c4/systems/network/net
import c4/systems/input/sdl as sdl_input
import c4/systems/physics/simple

import ./threads
import ./systems/video
import ./systems/network
import ./systems/input
import ./systems/physics

import ./scenarios/master


when isMainModule:

  spawnProcess "server":

    spawnThread physicsThread:
      threadName = "physics"

      var physics = new(physics.PhysicsSystem)
      physics.process(new(PhysicsInitMessage))
      physics.run(frequency=60)

    spawnThread networkThread:
      threadName = "network"

      var network = new(network.ServerNetworkSystem)
      network.process((ref ServerInitMessage)())
      network.run()

    joinActiveThreads()

  spawnProcess "client":

    spawnThread networkThread:
      threadName = "network"

      var network = new(network.ClientNetworkSystem)
      network.process((ref ClientInitMessage)())
      network.run()

    spawnThread videoThread:
      threadName = "video"

      var video = new(video.VideoSystem)
      video.process((ref VideoInitMessage)())
      video.run(frequency=60)

    spawnThread inputThread:
      threadName = "input"

      var input = new(input.InputSystem)
      input.process((ref InputInitMessage)())
      input.run(frequency=60)

    for thread in @[networkThread, videoThread, inputThread]:
      probe(thread, timeout=initDuration(seconds=5))

    # when all threads started, connect to the server
    new(ConnectMessage).send(networkThread)

    joinActiveThreads()

  joinProcesses()
