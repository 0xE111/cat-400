from logging import Level
from utils.loading import load

from systems.input import InputSystem
from systems.network import NetworkSystem
from systems.video import VideoSystem, Window
from systems.physics import PhysicsSystem


type
  Mode* = enum
    client, server, both

  Config* = tuple[
    title: string,
    version: string,
    logLevel: logging.Level,
    systems: tuple[
      physics: tuple[
        instance: ref PhysicsSystem,
      ],
      input: tuple[
        instance: ref InputSystem,
      ],
      network: tuple[
        instance: ref NetworkSystem,
        port: uint16,
      ],
      video: tuple[
        instance: ref VideoSystem,
        window: Window,
      ],
    ],
  ]
  
var
  config*: Config = (
    title: "",
    version: "0.0",
    logLevel: logging.Level.lvlWarn,
    systems: (
      physics: (
        instance: new(ref PhysicsSystem),
      ),
      input: (
        instance: new(ref InputSystem),
      ),
      network: (
        instance: new(ref NetworkSystem),
        port: 11477'u16,
      ),
      video: (
        instance: new(ref VideoSystem),
        window: (
          x: 400,
          y: 400,
          width: 600,
          height: 400,
          fullscreen: false,
        ),
      )
    ),
  )
