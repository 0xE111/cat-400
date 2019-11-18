import times


type
  Callback* = proc(dt: float): bool {.closure.}


# TODO: make async?
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
