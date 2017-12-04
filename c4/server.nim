from logging import nil
from utils.loop import runLoop, getFps

    
proc update(dt:float) =
  discard

proc start*() =
  runLoop(updatesPerSecond = 30, fixedFrequencyHandlers = @[update])
