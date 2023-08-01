import times
import os
import logging
import strutils

when isMainModule:
  import unittest


template loop*(frequency: int, code: untyped) =
  let skipSeconds = 1 / frequency

  var
    now = epochTime()
    lastUpdateTime = now
    dt {.inject.}: type(now)
    sleepTime: type(now)

  while true:
    now = epochTime()
    dt = now - lastUpdateTime
    lastUpdateTime = now

    code

    now = epochTime()

    if frequency != 0:
      sleepTime = lastUpdateTime + skipSeconds - now
      if sleepTime > 0:
        sleep(int(sleepTime * 1000))
      else:
        logging.warn "Loop step taking more time (" & $formatFloat(now - lastUpdateTime, precision=3) & "s) than desired frequency allows (" & $frequency & "Hz == " & $formatFloat(1/frequency, precision=3) & "s per step) at " & $instantiationInfo()


when isMainModule:
  var logger = newConsoleLogger()
  logging.addHandler(logger)

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
