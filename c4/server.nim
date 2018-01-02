from logging import nil
from utils.loop import runLoop
from utils.classes import Command
from utils.states import State, None, switch


type
  Loading* = object of State
  Running* = object of State
  Paused* = object of State

var state: ref State = new(ref None)  # TODO: add "not nil"

proc update(dt:float): bool =
  return not (state of ref None)

proc start*() =
  state = state.switch(new(ref Loading))
  runLoop(updatesPerSecond = 30, fixedFrequencyHandlers = @[update])
  logging.debug("Server stopped")
