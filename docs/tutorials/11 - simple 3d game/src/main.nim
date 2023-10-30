import times

import sdl2

import c4/processes
import c4/threads
import c4/logging

import c4/systems
import c4/systems/video/ogre as ogre_video
import c4/systems/network/net
import c4/systems/input/sdl as sdl_input
import c4/systems/physics/ode

import ./threads
import ./systems/video
import ./systems/network
import ./systems/input
import ./systems/physics

# TODO: import all submodules automatically
import ./scenarios/[
  hello,
  entity_create,
  entity_move,
  player,
]


when isMainModule:

  spawnProcess "server":

    spawnThread physicsThread:
      threadName = "physics"

      var physics = new(physics.PhysicsSystem)
      physics.process(new(PhysicsInitMessage))
      physics.run()

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
      video.process((ref ogre_video.VideoInitMessage)(windowWidth: 1200, windowHeight: 800))
      video.run(frequency=60)

    spawnThread inputThread:
      threadName = "input"

      var input = new(input.InputSystem)
      input.process((ref InputInitMessage)())
      input.run(frequency=30)

    for thread in @[networkThread, videoThread, inputThread]:
      probe(thread, timeout=initDuration(seconds=5))

    # when all threads started, connect to the server
    new(ConnectMessage).send(networkThread)

    joinActiveThreads()

  joinProcesses()
