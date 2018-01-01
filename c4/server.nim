from logging import nil
from utils.loop import runLoop, getFps
from utils.classes import Command


type
  State* = object of RootObj
  Loading* = object of State
  Running* = object of State
  Paused* = object of State

var state: ref State = nil
    
proc update(dt:float) =
  discard
  
method switch*(fr: ref State, to: ref State) =  # TODO: rename "fr" to "from"
  echo("Default switch")

import "sample/states"

proc start*() =
  state.switch(new(ref Loading))
  runLoop(updatesPerSecond = 30, fixedFrequencyHandlers = @[update])
