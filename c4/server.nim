from logging import nil
from utils.loop import runLoop, getFps
from utils.classes import Command, State

type
  Loading* = object of State
  Running* = object of State
  Paused* = object of State

var state: ref State = nil
    
proc update(dt:float) =
  discard
  
method switch*(fromState: ref State, toState: ref) =
  echo("Default switch")


proc start*() =
  state.switch(new(ref Loading))
  runLoop(updatesPerSecond = 30, fixedFrequencyHandlers = @[update])
