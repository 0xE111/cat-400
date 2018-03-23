from logging import Level
from utils.loading import load

from systems.input import InputSystem
from systems.network import NetworkSystem
from systems.video import VideoSystem, Window


type
  Mode* {.pure.} = enum
    default, server

  Config* = tuple[
    title: string,
    version: string,
    logLevel: logging.Level,
    mode: Mode,
    systems: tuple[
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
    mode: Mode.default,
    systems: (
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
          width: 400,
          height: 300,
          fullscreen: false,
        ),
      )
    ),
  )
