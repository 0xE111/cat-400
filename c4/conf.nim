from logging import nil
import server
import client


type
  Mode* {.pure.} = enum
    default, server

  Config* = tuple[
    # may use currentSourcePath()
    version: string,
    logLevel: logging.Level,
    mode: Mode,
    server: server.Config,
    client: client.Config,
  ]

var
  config*: Config = (
    version: "0.0",
    logLevel: logging.Level.lvlWarn,
    mode: Mode.default,
    server: (
      port: 11477'u16,
    ),
    client: (
    ),
  )
