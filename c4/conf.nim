from logging import nil


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
    ]
  ]

const
  networkSystemPath* {.strdefine.}: string = "wrappers/enet/enet/client"
  videoSystemPath* {.strdefine.}: string = "systems/video"

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
        width: 400,
        height: 300,
        fullscreen: false,
      ),
    ),
  )
