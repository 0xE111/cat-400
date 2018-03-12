from logging import Level
from utils.helpers import importOrFallback

importOrFallback "systems/input"


type
  Mode* {.pure.} = enum
    default, server

  Window* = tuple[
    x, y, width, height: int,
    fullscreen: bool,
  ]

  Config* = tuple[
    # may use currentSourcePath()
    title: string,
    version: string,
    logLevel: logging.Level,
    mode: Mode,
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
