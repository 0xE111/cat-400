import logging
import parseopt
import strutils


proc getCmdLogLevel*(): logging.Level =
  ## Scans command-line arguments for "--loglevel" or "-l" and returns specified log level.
  ## Returns lvlInfo by default.

  for kind, key, value in parseopt.getopt():
    if (kind == cmdLongOption and key == "loglevel") or (kind == cmdShortOption and key == "l"):
      return parseEnum[logging.Level]("lvl" & value)

  return logging.Level.lvlInfo
