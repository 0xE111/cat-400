from logging import nil


type
  Mode* {.pure.} = enum
    default, server

  Window* = tuple[
    x, y, width, height: int,
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
  networkSystemPath* {.strdefine.}: string = "wrappers/nimenet/nimenet"
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
        x: 480,
        y: 234,
        width: 400,
        height: 300,
      ),
    ),
  )
