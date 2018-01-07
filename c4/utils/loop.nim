import times


type
  UpdateProc* = proc(dt: float): bool

proc runLoop*(updatesPerSecond = 30, fixedFrequencyHandlers:seq[UpdateProc] = @[], maxFrequencyHandlers:seq[UpdateProc] = @[]) =
  # handlers will receive dt - delta time between two last calls
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
        if not handler(now - lastFixedUpdateTime):
          return

      lastFixedUpdateTime = now
      nextFixedUpdateTime += skipSeconds
      numUpdates += 1
    
    now = times.epochTime()
    for handler in maxFrequencyHandlers:
      if not handler(now - lastMaxUpdateTime):
        return
    lastMaxUpdateTime = now

proc getFps*(dt:float): int =
  ## Calculates *very* approximate FPS value based on dt received by loop handlers. Example:
  ## proc printFps(dt:float) = 
  ##   echo "Max FPS is: ", $getFps(dt)
  ## runLoop(maxFrequencyHandlers = @[printFps])
  result = int(1.float / dt)
