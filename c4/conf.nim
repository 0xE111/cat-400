from logging import Level
from utils.loading import load

from systems.input import InputSystem


type
  Mode* {.pure.} = enum
    default, server

  Window* = tuple[
    x, y, width, height: int,
    fullscreen: bool,
  ]

  Config* = tuple[
    title: string,
    version: string,
    logLevel: logging.Level,
    mode: Mode,
    systems: tuple[
      input: ref InputSystem,
    ],
    network: tuple[
      port: uint16,
    ],
    video: tuple[
      window: Window,
    ],
  ]
  
var
  config*: Config = (
    title: "",
    version: "0.0",
    logLevel: logging.Level.lvlWarn,
    mode: Mode.default,
    systems: (
      input: new(ref InputSystem),
    ),
    network: (
      port: 11477'u16,
    ),
    video: (
      window: (
        x: 400,
        y: 400,
        width: 600,
        height: 450,
        fullscreen: false,
      ),
    ),
  )
