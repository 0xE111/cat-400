from times import epochTime


type
  Callback* = proc(dt: float): bool {.closure.}


proc runLoop*(
  updatesPerSecond = 30,
  fixedFrequencyCallback: Callback = nil,
  maxFrequencyCallback: Callback = nil,
) =
  # handlers will receive dt - delta time between two last calls
  let 
    skipSeconds = 1 / updatesPerSecond
    maxUpdatesSkip = int(updatesPerSecond.float * 0.3)

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
      if fixedFrequencyCallback != nil and not fixedFrequencyCallback(now - lastFixedUpdateTime):
        return

      lastFixedUpdateTime = now
      nextFixedUpdateTime += skipSeconds
      numUpdates += 1
    
    now = epochTime()
    if maxFrequencyCallback != nil and not maxFrequencyCallback(now - lastMaxUpdateTime):
      return
    lastMaxUpdateTime = now

proc getFps*(dt:float): int =
  ## Calculates *very* approximate FPS value based on dt received by loop handlers. Example:
  ## proc printFps(dt:float) = 
  ##   echo "Max FPS is: ", $getFps(dt)
  ## runLoop(maxFrequencyHandlers = @[printFps])
  result = int(1.float / dt)
