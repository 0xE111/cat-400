from logging import nil
from utils.loop import runLoop
from utils.classes import Command
from utils.states import State, switch


type
  Loading* = object of State
  Running* = object of State
  Paused* = object of State

var state: ref State = nil

proc update(dt:float) =
  discard

proc start*() =
  state = state.switch(new(ref Loading))
  runLoop(updatesPerSecond = 30, fixedFrequencyHandlers = @[update])
