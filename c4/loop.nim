import times
import os
import strutils

import ./logging


type BreakLoopException* = object of CatchableError


template loop*(frequency: int, code: untyped) =
  let skipSeconds = 1 / frequency

  var
    now = epochTime()
    lastUpdateTime = now
    dt {.inject.}: type(now)
    sleepTime: type(now)

  while true:
    trace "loop tick"
    now = epochTime()
    dt = now - lastUpdateTime
    lastUpdateTime = now

    try:
      code
    except BreakLoopException:
      break

    now = epochTime()

    if frequency != 0:
      sleepTime = lastUpdateTime + skipSeconds - now
      if sleepTime > 0:
        trace "loop sleep", sleepTime
        sleep(int(sleepTime * 1000))
      else:
        logging.warn "loop lag", timeTakenPerStep=formatFloat(now - lastUpdateTime, precision=3), desiredFrequency=frequency, maxAllowedTimePerStep=formatFloat(1/frequency, precision=3)


when isMainModule:
  import unittest

  suite "Loop":
    test "Base loop frequency":
      var i = 0
      loop(30) do:
        echo $i & " " & $dt
        if i == 0:
          assert dt < 0.01
        else:
          assert dt < 0.035 and dt > 0.025
        inc i
        if i > 30:
          break

    test "Warnings":
      var i = 0
      loop(30) do:
        echo $i
        sleep(500)
        inc i
        if i > 3:
          break
