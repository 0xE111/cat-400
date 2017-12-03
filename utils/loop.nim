import times

type
  UpdateProc = proc(dt: float) {.nimcall.}

proc runLoop*(updatesPerSecond = 30, fixedFrequencyHandlers:seq[UpdateProc] = @[], maxFrequencyHandlers:seq[UpdateProc] = @[]) =
  # handlers will receive dt - delta time between two last calls; you may use "getFps(dt)" proc from this module to calculate *very* approximate FPS value
  let 
    skipSeconds = 1 / updatesPerSecond
    maxUpdatesSkip = int(updatesPerSecond.float * 0.3)

  var
    numUpdates: int
    nextFixedUpdateTime = times.epochTime()  # in seconds, floating point
    lastFixedUpdateTime = nextFixedUpdateTime
    lastMaxUpdateTime = nextFixedUpdateTime
    now: float

  while true:
    # following block is called once every frame; however, if we missed several frames, it will try to catch up by running up to maxUpdateSkip times
    numUpdates = 0
    while (times.epochTime() > nextFixedUpdateTime) and (numUpdates < maxUpdatesSkip):
      now = times.epochTime()
      for handler in fixedFrequencyHandlers:
        handler(now - lastFixedUpdateTime)

      lastFixedUpdateTime = now
      nextFixedUpdateTime += skipSeconds
      numUpdates += 1
    
    now = times.epochTime()
    for handler in maxFrequencyHandlers:
      handler(now - lastMaxUpdateTime)
    lastMaxUpdateTime = now

proc getFps*(dt:float): int =
  result = int(1.float / dt)
