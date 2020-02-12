import times
import os
import logging
import strutils

when isMainModule:
  import unittest


template loop*(frequency: int = 30, code: untyped) =
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
    sleepTime = lastUpdateTime + skipSeconds - now
    if sleepTime > 0:
      sleep(int(sleepTime * 1000))
    else:
      logging.warn "Loop step taking more time (" & $(now - lastUpdateTime).formatFloat(precision=3) & "s) than desired frequency allows (" & $frequency & "Hz == " & $(1/frequency).formatFloat(precision=3) & "s per step) at " & $instantiationInfo()


template loop*(frequency: int = 30, fixedFrequencyCode: untyped, maxFrequencyCode: untyped) =
  # handlers will receive dt - delta time between two last calls (in seconds, floating point)
  let
    skipSeconds = 1 / frequency
    maxUpdatesSkip = int(frequency.float * 0.3)

  var
    numUpdates: int
    nextFixedUpdateTime = epochTime()  # in seconds, floating point
    lastFixedUpdateTime = nextFixedUpdateTime
    lastMaxUpdateTime = nextFixedUpdateTime
    now: float

  while true:
    # following block is called once every frame; however, if we missed several frames, it will try to catch up by running up to maxUpdateSkip times
    numUpdates = 0
    while (epochTime() > nextFixedUpdateTime) and (numUpdates < maxUpdatesSkip):
      now = epochTime()
      block:
        let dt {.inject.} = now - lastFixedUpdateTime
        fixedFrequencyCode

      lastFixedUpdateTime = now
      nextFixedUpdateTime += skipSeconds
      numUpdates += 1

    now = epochTime()
    block:
      let dt {.inject.} = now - lastMaxUpdateTime
      maxFrequencyCode
    lastMaxUpdateTime = now


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
